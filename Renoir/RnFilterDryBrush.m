//
//  RnFilterDryBrush.m
//  Renoir
//
//  Created by SSC on 2014/05/17.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnFilterDryBrush.h"

@implementation RnFilterDryBrush

@synthesize texelSpacingMultiplier = _texelSpacingMultiplier;
@synthesize blurRadiusInPixels = _blurRadiusInPixels;
@synthesize blurRadiusAsFractionOfImageWidth  = _blurRadiusAsFractionOfImageWidth;
@synthesize blurRadiusAsFractionOfImageHeight = _blurRadiusAsFractionOfImageHeight;
@synthesize blurPasses = _blurPasses;
@synthesize intensityLevel = _intensityLevel;

#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithFirstStageVertexShaderFromString:(NSString *)firstStageVertexShaderString firstStageFragmentShaderFromString:(NSString *)firstStageFragmentShaderString secondStageVertexShaderFromString:(NSString *)secondStageVertexShaderString secondStageFragmentShaderFromString:(NSString *)secondStageFragmentShaderString
{
    if (!(self = [super initWithFirstStageVertexShaderFromString:firstStageVertexShaderString firstStageFragmentShaderFromString:firstStageFragmentShaderString secondStageVertexShaderFromString:secondStageVertexShaderString secondStageFragmentShaderFromString:secondStageFragmentShaderString]))
    {
        return nil;
    }
    
    self.texelSpacingMultiplier = 1.0;
    _blurRadiusInPixels = 2.0;
    shouldResizeBlurRadiusWithImageSize = NO;
    
    return self;
}

- (id)init;
{
    _intensityLevel = 32;
    NSString *currentGaussianBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfRadius:4 sigma:2.0];
    NSString *currentGaussianBlurFragmentShader = [self fragmentShaderForOptimizedBlurOfRadius:4 sigma:2.0];
    
    return [self initWithFirstStageVertexShaderFromString:currentGaussianBlurVertexShader firstStageFragmentShaderFromString:currentGaussianBlurFragmentShader secondStageVertexShaderFromString:currentGaussianBlurVertexShader secondStageFragmentShaderFromString:currentGaussianBlurFragmentShader];
}

#pragma mark -
#pragma mark Auto-generation of optimized Gaussian shaders

// "Implementation limit of 32 varying components exceeded" - Max number of varyings for these GPUs

+ (NSString *)vertexShaderForStandardBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
{
    if (blurRadius < 1)
    {
        return kGPUImageVertexShaderString;
    }
    
    //    NSLog(@"Max varyings: %d", [GPUImageContext maximumVaryingVectorsForThisDevice]);
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
    [shaderString appendFormat:@"\
     attribute vec4 position;\n\
     attribute vec4 inputTextureCoordinate;\n\
     \n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     \n\
     varying vec2 blurCoordinates[%lu];\n\
     \n\
     void main()\n\
     {\n\
     gl_Position = position;\n\
     \n\
     vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n", (unsigned long)(blurRadius * 2 + 1) ];
    
    // Inner offset loop
    for (NSUInteger currentBlurCoordinateIndex = 0; currentBlurCoordinateIndex < (blurRadius * 2 + 1); currentBlurCoordinateIndex++)
    {
        NSInteger offsetFromCenter = currentBlurCoordinateIndex - blurRadius;
        if (offsetFromCenter < 0)
        {
            [shaderString appendFormat:@"blurCoordinates[%ld] = inputTextureCoordinate.xy - singleStepOffset * %f;\n", (unsigned long)currentBlurCoordinateIndex, (GLfloat)(-offsetFromCenter)];
        }
        else if (offsetFromCenter > 0)
        {
            [shaderString appendFormat:@"blurCoordinates[%ld] = inputTextureCoordinate.xy + singleStepOffset * %f;\n", (unsigned long)currentBlurCoordinateIndex, (GLfloat)(offsetFromCenter)];
        }
        else
        {
            [shaderString appendFormat:@"blurCoordinates[%ld] = inputTextureCoordinate.xy;\n", (unsigned long)currentBlurCoordinateIndex];
        }
    }
    
    // Footer
    [shaderString appendString:@"}\n"];
    
    return shaderString;
}

+ (NSString *)vertexShaderForOptimizedBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
{
    if (blurRadius < 1)
    {
        return kGPUImageVertexShaderString;
    }
    
    // First, generate the normal Gaussian weights for a given sigma
    GLfloat *standardGaussianWeights = calloc(blurRadius + 1, sizeof(GLfloat));
    GLfloat sumOfWeights = 0.0;
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = (1.0 / sqrt(2.0 * M_PI * pow(sigma, 2.0))) * exp(-pow(currentGaussianWeightIndex, 2.0) / (2.0 * pow(sigma, 2.0)));
        
        if (currentGaussianWeightIndex == 0)
        {
            sumOfWeights += standardGaussianWeights[currentGaussianWeightIndex];
        }
        else
        {
            sumOfWeights += 2.0 * standardGaussianWeights[currentGaussianWeightIndex];
        }
    }
    
    // Next, normalize these weights to prevent the clipping of the Gaussian curve at the end of the discrete samples from reducing luminance
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = standardGaussianWeights[currentGaussianWeightIndex] / sumOfWeights;
    }
    
    // From these weights we calculate the offsets to read interpolated values from
    NSUInteger numberOfOptimizedOffsets = MIN(blurRadius / 2 + (blurRadius % 2), 7);
    GLfloat *optimizedGaussianOffsets = calloc(numberOfOptimizedOffsets, sizeof(GLfloat));
    
    for (NSUInteger currentOptimizedOffset = 0; currentOptimizedOffset < numberOfOptimizedOffsets; currentOptimizedOffset++)
    {
        GLfloat firstWeight = standardGaussianWeights[currentOptimizedOffset*2 + 1];
        GLfloat secondWeight = standardGaussianWeights[currentOptimizedOffset*2 + 2];
        
        GLfloat optimizedWeight = firstWeight + secondWeight;
        
        optimizedGaussianOffsets[currentOptimizedOffset] = (firstWeight * (currentOptimizedOffset*2 + 1) + secondWeight * (currentOptimizedOffset*2 + 2)) / optimizedWeight;
    }
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    // Header
    [shaderString appendFormat:@"\
     attribute vec4 position;\n\
     attribute vec4 inputTextureCoordinate;\n\
     \n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     \n\
     varying vec2 blurCoordinates[%lu];\n\
     \n\
     void main()\n\
     {\n\
     gl_Position = position;\n\
     \n\
     vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);\n", (unsigned long)(1 + (numberOfOptimizedOffsets * 2))];
    
    // Inner offset loop
    [shaderString appendString:@"blurCoordinates[0] = inputTextureCoordinate.xy;\n"];
    for (NSUInteger currentOptimizedOffset = 0; currentOptimizedOffset < numberOfOptimizedOffsets; currentOptimizedOffset++)
    {
        [shaderString appendFormat:@"\
         blurCoordinates[%lu] = inputTextureCoordinate.xy + singleStepOffset * %f;\n\
         blurCoordinates[%lu] = inputTextureCoordinate.xy - singleStepOffset * %f;\n", (unsigned long)((currentOptimizedOffset * 2) + 1), optimizedGaussianOffsets[currentOptimizedOffset], (unsigned long)((currentOptimizedOffset * 2) + 2), optimizedGaussianOffsets[currentOptimizedOffset]];
    }
    
    // Footer
    [shaderString appendString:@"}\n"];
    
    free(optimizedGaussianOffsets);
    free(standardGaussianWeights);
    return shaderString;
}

- (NSString *)fragmentShaderForOptimizedBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
{
    if (blurRadius < 1)
    {
        return kGPUImagePassthroughFragmentShaderString;
    }
    
    // First, generate the normal Gaussian weights for a given sigma
    GLfloat *standardGaussianWeights = calloc(blurRadius + 1, sizeof(GLfloat));
    GLfloat sumOfWeights = 0.0;
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = (1.0 / sqrt(2.0 * M_PI * pow(sigma, 2.0))) * exp(-pow(currentGaussianWeightIndex, 2.0) / (2.0 * pow(sigma, 2.0)));
        
        if (currentGaussianWeightIndex == 0)
        {
            sumOfWeights += standardGaussianWeights[currentGaussianWeightIndex];
        }
        else
        {
            sumOfWeights += 2.0 * standardGaussianWeights[currentGaussianWeightIndex];
        }
    }
    
    // Next, normalize these weights to prevent the clipping of the Gaussian curve at the end of the discrete samples from reducing luminance
    for (NSUInteger currentGaussianWeightIndex = 0; currentGaussianWeightIndex < blurRadius + 1; currentGaussianWeightIndex++)
    {
        standardGaussianWeights[currentGaussianWeightIndex] = standardGaussianWeights[currentGaussianWeightIndex] / sumOfWeights;
    }
    
    // From these weights we calculate the offsets to read interpolated values from
    NSUInteger numberOfOptimizedOffsets = MIN(blurRadius / 2 + (blurRadius % 2), 7);
    NSUInteger trueNumberOfOptimizedOffsets = blurRadius / 2 + (blurRadius % 2);
    
    NSMutableString *shaderString = [[NSMutableString alloc] init];
    
    // Header
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [shaderString appendFormat:@"\
     uniform sampler2D inputImageTexture;\n\
     uniform highp float texelWidthOffset;\n\
     uniform highp float texelHeightOffset;\n\
     \n\
     varying highp vec2 blurCoordinates[%lu];\n\
     lowp float intensity_level = %f;\n\
     \n\
     mediump float round(mediump float a){\n\
         mediump float b = floor(a);\n\
         b = floor((a - b) * 10.0);\n\
         if(int(b) < 5){\n\
             return floor(a);\n\
         }\n\
         return ceil(a);\n\
     }\n\
     void main()\n\
     {\n", (unsigned long)(1 + (numberOfOptimizedOffsets * 2)), _intensityLevel / 255.0f ];
#else
    [shaderString appendFormat:@"\
     uniform sampler2D inputImageTexture;\n\
     uniform float texelWidthOffset;\n\
     uniform float texelHeightOffset;\n\
     \n\
     varying vec2 blurCoordinates[%lu];\n\
     lowp float intensity_level = %f;\n\
     \n\
     float round(float a){\n\
     float b = floor(a);\n\
     b = floor((a - b) * 10.0);\n\
     if(int(b) < 5){\n\
     return floor(a);\n\
     }\n\
     return ceil(a);\n\
     }\n\
     void main()\n\
     {\n", 1 + (numberOfOptimizedOffsets * 2), intensityLevel / 255.0f ];
#endif
    
    int max_length = _intensityLevel;
    
    [shaderString appendFormat:@"\
     mediump float sumR[%d];\n\
     mediump float sumG[%d];\n\
     mediump float sumB[%d];\n\
     mediump int intensity_count[%d];\n\
     mediump float current_intensity = 0.0;\n\
     mediump vec4 pixel;\n\
     int index = 0;\n\
     int curMax = 0;\n\
     int maxIndex = 0;\n\
     for(int i = 0;i < %d;i++){\n\
        sumR[i] = 0.0;\n\
        sumG[i] = 0.0;\n\
        sumB[i] = 0.0;\n\
        intensity_count[i] = 0;\n\
     }\n\
     \n", max_length, max_length, max_length, max_length, max_length];

    /*
    [shaderString appendFormat:@"\
     pixel = texture2D(inputImageTexture, blurCoordinates[0]);\n\
     current_intensity = (pixel.r / 3.0 + pixel.g / 3.0 + pixel.b / 3.0) * intensity_level;\n\
     index = int(round(current_intensity * 255.0));\n\
     intensity_count[index] += 1;\n\
     sumR[index] += pixel.r;\n\
     sumG[index] += pixel.g;\n\
     sumB[index] += pixel.b;\n\
     if(curMax < intensity_count[index]){\n\
        curMax = intensity_count[index];\n\
        maxIndex = index;\n\
     }\n\
     \n"];
    
    for (NSUInteger currentBlurCoordinateIndex = 0; currentBlurCoordinateIndex < numberOfOptimizedOffsets; currentBlurCoordinateIndex++)
    {
        GLfloat firstWeight = standardGaussianWeights[currentBlurCoordinateIndex * 2 + 1];
        GLfloat secondWeight = standardGaussianWeights[currentBlurCoordinateIndex * 2 + 2];
        GLfloat optimizedWeight = firstWeight + secondWeight;
        
        [shaderString appendFormat:@"\
         pixel = texture2D(inputImageTexture, blurCoordinates[%lu]);\n\
         current_intensity = (pixel.r / 3.0 + pixel.g / 3.0 + pixel.b / 3.0) * intensity_level;\n\
         index = int(round(current_intensity * 255.0));\n\
         intensity_count[index] += 1;\n\
         sumR[index] += pixel.r;\n\
         sumG[index] += pixel.g;\n\
         sumB[index] += pixel.b;\n\
         if(curMax < intensity_count[index]){\n\
            curMax = intensity_count[index];\n\
            maxIndex = index;\n\
         }\n\
         \n", (unsigned long)((currentBlurCoordinateIndex * 2) + 1)];
        
        [shaderString appendFormat:@"\
         pixel = texture2D(inputImageTexture, blurCoordinates[%lu]);\n\
         current_intensity = (pixel.r / 3.0 + pixel.g / 3.0 + pixel.b / 3.0) * intensity_level;\n\
         index = int(round(current_intensity * 255.0));\n\
         intensity_count[index] += 1;\n\
         sumR[index] += pixel.r;\n\
         sumG[index] += pixel.g;\n\
         sumB[index] += pixel.b;\n\
         if(curMax < intensity_count[index]){\n\
            curMax = intensity_count[index];\n\
            maxIndex = index;\n\
         }\n\
         \n", (unsigned long)((currentBlurCoordinateIndex * 2) + 2)];
    }
    */
    
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [shaderString appendFormat:@"\
     highp vec2 widthStep = vec2(texelWidthOffset, 0.0);\n\
     highp vec2 heightStep = vec2(0.0, texelHeightOffset);\n"];
#else
    [shaderString appendFormat:@"\
     vec2 widthStep = vec2(texelWidthOffset, 0.0);\n\
     vec2 heightStep = vec2(0.0, texelHeightOffset);\n"];
#endif
    
    int r2 = sigma * sigma;
    int cr = 0;
    
    for (int x = -(int)sigma; x <= (int)sigma; x++) {
        for(int y = -(int)sigma; y <= (int)sigma; y++){
            cr = x * x + y * y;
            if (cr > r2) {
                continue;
            }
            [shaderString appendFormat:@"\
             pixel = texture2D(inputImageTexture, blurCoordinates[0] + widthStep * %f + heightStep * %f);\n\
             current_intensity = (pixel.r / 3.0 + pixel.g / 3.0 + pixel.b / 3.0) * intensity_level;\n\
             index = int(floor(current_intensity * 255.0));\n\
             intensity_count[index] += 1;\n\
             sumR[index] += pixel.r;\n\
             sumG[index] += pixel.g;\n\
             sumB[index] += pixel.b;\n\
             \n", (float)x, (float)y];
        }
    }
    
    
    // Footer
    [shaderString appendFormat:@"\
     maxIndex = 0;\n\
     curMax = intensity_count[maxIndex];\n\
     for( int i = 1; i < %d; i++ ) {\n\
         if( intensity_count[i] > curMax ) {\n\
             curMax = intensity_count[i];\n\
             maxIndex = i;\n\
         }\n\
     }\n\
     if(curMax > 0){\n\
        pixel.r = sumR[maxIndex] / float(curMax);\n\
        pixel.g = sumG[maxIndex] / float(curMax);\n\
        pixel.b = sumB[maxIndex] / float(curMax);\n\
     }\n\
     gl_FragColor = pixel;\n\
     }\n", max_length];
    
    free(standardGaussianWeights);
    //NSLog(shaderString);
    return shaderString;
}

- (void)setupFilterForSize:(CGSize)filterFrameSize;
{
    [super setupFilterForSize:filterFrameSize];
    
    verticalPassTexelWidthOffset = 1.0 / filterFrameSize.width;
    horizontalPassTexelHeightOffset = 1.0 / filterFrameSize.height;
    
    if (shouldResizeBlurRadiusWithImageSize == YES)
    {
        
    }
}

#pragma mark -
#pragma mark Rendering

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
{
    [super renderToTextureWithVertices:vertices textureCoordinates:textureCoordinates sourceTexture:sourceTexture];
    
    for (NSUInteger currentAdditionalBlurPass = 1; currentAdditionalBlurPass < _blurPasses; currentAdditionalBlurPass++)
    {
        [super renderToTextureWithVertices:vertices textureCoordinates:[[self class] textureCoordinatesForRotation:kGPUImageNoRotation] sourceTexture:secondFilterOutputTexture];
    }
}

- (void)switchToVertexShader:(NSString *)newVertexShader fragmentShader:(NSString *)newFragmentShader;
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        filterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:newVertexShader fragmentShaderString:newFragmentShader];
        
        if (!filterProgram.initialized)
        {
            [self initializeAttributes];
            
            if (![filterProgram link])
            {
                NSString *progLog = [filterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [filterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [filterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                filterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        filterPositionAttribute = [filterProgram attributeIndex:@"position"];
        filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
        filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        verticalPassTexelWidthOffsetUniform = [filterProgram uniformIndex:@"texelWidthOffset"];
        verticalPassTexelHeightOffsetUniform = [filterProgram uniformIndex:@"texelHeightOffset"];
        [GPUImageContext setActiveShaderProgram:filterProgram];
        
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
        
        secondFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:newVertexShader fragmentShaderString:newFragmentShader];
        
        if (!secondFilterProgram.initialized)
        {
            [self initializeSecondaryAttributes];
            
            if (![secondFilterProgram link])
            {
                NSString *progLog = [secondFilterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [secondFilterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [secondFilterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                secondFilterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        secondFilterPositionAttribute = [secondFilterProgram attributeIndex:@"position"];
        secondFilterTextureCoordinateAttribute = [secondFilterProgram attributeIndex:@"inputTextureCoordinate"];
        secondFilterInputTextureUniform = [secondFilterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        secondFilterInputTextureUniform2 = [secondFilterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader
        horizontalPassTexelWidthOffsetUniform = [secondFilterProgram uniformIndex:@"texelWidthOffset"];
        horizontalPassTexelHeightOffsetUniform = [secondFilterProgram uniformIndex:@"texelHeightOffset"];
        [GPUImageContext setActiveShaderProgram:secondFilterProgram];
        
        glEnableVertexAttribArray(secondFilterPositionAttribute);
        glEnableVertexAttribArray(secondFilterTextureCoordinateAttribute);
        
        [self setupFilterForSize:[self sizeOfFBO]];
        glFinish();
    });
    
}

#pragma mark -
#pragma mark Accessors

- (void)setTexelSpacingMultiplier:(CGFloat)newValue;
{
    _texelSpacingMultiplier = newValue;
    
    _verticalTexelSpacing = _texelSpacingMultiplier;
    _horizontalTexelSpacing = _texelSpacingMultiplier;
    
    [self setupFilterForSize:[self sizeOfFBO]];
}

- (void)setIntensityLevel:(int)intensityLevel
{
    _intensityLevel = intensityLevel;
    [self setBlurRadiusInPixels:_blurRadiusInPixels];
}

// inputRadius for Core Image's CIGaussianBlur is really sigma in the Gaussian equation, so I'm using that for my blur radius, to be consistent
- (void)setBlurRadiusInPixels:(CGFloat)newValue;
{
    // 7.0 is the limit for blur size for hardcoded varying offsets
    
    
    _blurRadiusInPixels = round(newValue); // For now, only do integral sigmas
    
    // Calculate the number of pixels to sample from by setting a bottom limit for the contribution of the outermost pixel
    CGFloat minimumWeightToFindEdgeOfSamplingArea = 1.0/256.0;
    NSUInteger calculatedSampleRadius = floor(sqrt(-2.0 * pow(_blurRadiusInPixels, 2.0) * log(minimumWeightToFindEdgeOfSamplingArea * sqrt(2.0 * M_PI * pow(_blurRadiusInPixels, 2.0))) ));
    calculatedSampleRadius += calculatedSampleRadius % 2; // There's nothing to gain from handling odd radius sizes, due to the optimizations I use
    
    //        NSLog(@"Blur radius: %f, calculated sample radius: %d", _blurRadiusInPixels, calculatedSampleRadius);
    //
    NSString *newGaussianBlurVertexShader = [[self class] vertexShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:_blurRadiusInPixels];
    NSString *newGaussianBlurFragmentShader = [self fragmentShaderForOptimizedBlurOfRadius:calculatedSampleRadius sigma:_blurRadiusInPixels];
    
    //        NSLog(@"Optimized vertex shader: \n%@", newGaussianBlurVertexShader);
    //        NSLog(@"Optimized fragment shader: \n%@", newGaussianBlurFragmentShader);
    //
    [self switchToVertexShader:newGaussianBlurVertexShader fragmentShader:newGaussianBlurFragmentShader];
    
    shouldResizeBlurRadiusWithImageSize = NO;
}

@end
