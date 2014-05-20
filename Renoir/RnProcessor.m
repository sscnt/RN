//
//  RnProcessor.m
//  Renoir
//
//  Created by SSC on 2014/05/20.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnProcessor.h"

@implementation RnProcessor

static RnProcessor* sharedRnProcessor = nil;

+ (RnProcessor*)instance {
	@synchronized(self) {
		if (sharedRnProcessor == nil) {
			sharedRnProcessor = [[self alloc] init];
		}
	}
	return sharedRnProcessor;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedRnProcessor == nil) {
			sharedRnProcessor = [super allocWithZone:zone];
			return sharedRnProcessor;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone*)zone {
	return self;  // シングルトン状態を保持するため何もせず self を返す
}

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (void)updateCurrentProgress:(float)progress
{
    
}

#pragma mark api

+ (void)setRadius:(int)radius
{
    [self instance].radius = radius;
}

+ (UIImage *)executeWithImage:(UIImage *)image
{
    @autoreleasepool {
        UIImage* overlay = [self applyDryBrushToImage:image];
        image = [self mergeBaseImage:image overlayImage:overlay opacity:0.46f blendingMode:VnBlendingModeMultiply];
    }
    @autoreleasepool {
        GPUImageUnsharpMaskFilter* filter = [[GPUImageUnsharpMaskFilter alloc] init];
        filter.blurRadiusInPixels = 7.0f;
        filter.intensity = 3.0f;
        image = [self mergeBaseImage:image overlayFilter:filter opacity:1.0f blendingMode:VnBlendingModeNormal];
    }
    @autoreleasepool {
        UIImage* overlay = [self applyDryBrushToImage:image];
        image = [self mergeBaseImage:image overlayImage:overlay opacity:0.620f blendingMode:VnBlendingModeDarkerColor];
    }
    return image;
}

+ (UIImage *)applyDryBrushToImage:(UIImage *)image
{
    
    RnProcessor* rp = [self instance];
    
	// CGImageを取得する
	CGImageRef cgImage = image.CGImage;
    
	// 画像情報を取得する
	size_t width = CGImageGetWidth(cgImage);
	size_t height = CGImageGetHeight(cgImage);
	size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
	size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
	size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
	bool shouldInterpolate = CGImageGetShouldInterpolate(cgImage);
	CGColorRenderingIntent intent = CGImageGetRenderingIntent(cgImage);
    
    int index = 0;
    int intensity_count[256] = {0};
    int sumR[256] = {0};
    int sumG[256] = {0};
    int sumB[256] = {0};
    int current_intensity = 0;
    int X,Y, x,y;
    int curMax = 0;
    int maxIndex = 0;
    int RADIUS = rp.radius;
    int radius = RADIUS;
    int N = 0;
    double variance = 0.0;
    double average = 0.0;
    int intensity_level = 64;
    double max_variance = 0.0, min_variance = 1.0;
    UInt8 r, g, b;
    UInt8* pixel;
    
	// データプロバイダを取得する
	CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CFDataRef tmpData = CGDataProviderCopyData(dataProvider);
    CFDataRef tmpData2 = CGDataProviderCopyData(dataProvider);
    
    //CGDataProviderRelease(dataProvider);
    
    CFMutableDataRef outputData = CFDataCreateMutableCopy(0, 0, tmpData2);
    
    CFRelease(tmpData2);
    
    UInt8 *buffer = (UInt8 *)CFDataGetBytePtr(tmpData);
    UInt8 *pOutBuffer = (UInt8 *)CFDataGetMutableBytePtr(outputData);
    
    int r2 = radius * radius;
    int cr = 0;
    
    float progress = 0.0f;
    
    
	// ビットマップに効果を与える
	for (Y = RADIUS ; Y < (height - RADIUS); Y++)
	{
        progress = (float)Y / (float)(height - RADIUS - 1 - RADIUS);
        [self updateCurrentProgress:progress];
		for (X = RADIUS; X < (width - RADIUS); X++)
		{
            memset(&intensity_count[0], 0, sizeof(intensity_count));
            variance = 0.0;
            average = 0.0;
            radius = RADIUS;
            N = 0;
            memset(&sumR[0], 0, sizeof(sumR));
            memset(&sumG[0], 0, sizeof(sumG));
            memset(&sumB[0], 0, sizeof(sumB));
            
			// RGBの値を取得する
            
            /* Calculate the highest intensity Neighbouring Pixels. */
            for(y = -radius; y <= radius; y++) {
                for(x = -radius; x <= radius; x++) {
                    cr = x * x + y * y;
                    if (cr > r2) {
                        continue;
                    }
                    index = ((Y + y) * width * 4) + ((X + x) * 4);
                    pixel = buffer + index;
                    
                    r = *(pixel + 0);
                    g = *(pixel + 1);
                    b = *(pixel + 2);
                    
                    current_intensity = ((r + g + b) * intensity_level/3.0)/255;
                    
                    //NSLog(@"(%d, %d) rgb = %d, %d, %d int = %d", X + x, Y + y, r, g, b, current_intensity);
                    
                    intensity_count[current_intensity]++;
                    sumR[current_intensity] += r;
                    sumG[current_intensity] += g;
                    sumB[current_intensity] += b;
                }
            }
            index = (Y * width * 4) + (X * 4);
            
            maxIndex = 0;
            curMax = intensity_count[maxIndex];
            for( int i = 0; i < intensity_level; i++ ) {
                if( intensity_count[i] > curMax ) {
                    curMax = intensity_count[i];
                    maxIndex = i;
                }
            }
            
            if(curMax > 0) {
                UInt8* tmp = pOutBuffer + index;
                *(tmp + 0) = sumR[maxIndex]/curMax;
                *(tmp + 1) = sumG[maxIndex]/curMax;
                *(tmp + 2) = sumB[maxIndex]/curMax;
                
                //NSLog(@"###(%d, %d) rgb = %d, %d, %d", Y, X, *(tmp), *(tmp+1), *(tmp+2));
                
                
                //pOutBuffer[index + 0] = sumR[maxIndex]/curMax;
                //pOutBuffer[index + 1] = sumG[maxIndex]/curMax;
                //pOutBuffer[index + 2] = sumB[maxIndex]/curMax;
            }
            
		}
    }
    
    NSLog(@"max: %lf", max_variance);
    NSLog(@"min: %lf", min_variance);
    
    CFIndex length = CFDataGetLength(tmpData);
	CFRelease(tmpData);
    
    
	// 効果を与えたデータを作成する
	CFDataRef effectedData = CFDataCreate(NULL, pOutBuffer, length);
    
    
    
	// 効果を与えたデータプロバイダを作成する
	CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
	// 画像を作成する
	CGImageRef effectedCgImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, effectedDataProvider, NULL, shouldInterpolate, intent);
	CGDataProviderRelease(effectedDataProvider);
    
    UIImage* effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
	// 作成したデータを解放する
	CFRelease(effectedData);
	CGImageRelease(effectedCgImage);
    CGColorSpaceRelease(colorSpace);
    CFRelease(outputData);
    
    return effectedImage;

}


+ (UIImage*)mergeBaseImage:(UIImage *)baseImage overlayImage:(UIImage *)overlayImage opacity:(CGFloat)opacity blendingMode:(VnBlendingMode)blendingMode
{
    if (overlayImage == nil || baseImage == nil) {
        return nil;
    }
    GPUImagePicture* overlayPicture = [[GPUImagePicture alloc] initWithImage:overlayImage];
    GPUImageOpacityFilter* opacityFilter = [[GPUImageOpacityFilter alloc] init];
    opacityFilter.opacity = opacity;
    [overlayPicture addTarget:opacityFilter];
    
    GPUImagePicture* basePicture = [[GPUImagePicture alloc] initWithImage:baseImage];
    
    id blending = [self effectByBlendMode:blendingMode];
    [opacityFilter addTarget:blending atTextureLocation:1];
    
    [basePicture addTarget:blending];
    [basePicture processImage];
    [overlayPicture processImage];
    return [blending imageFromCurrentlyProcessedOutput];
    
}

+ (UIImage*)mergeBaseImage:(UIImage *)baseImage overlayFilter:(GPUImageFilter *)overlayFilter opacity:(CGFloat)opacity blendingMode:(VnBlendingMode)blendingMode
{
    if (baseImage == nil) {
        return nil;
    }
    if (opacity == 1.0f) {
        
        GPUImagePicture* picture = [[GPUImagePicture alloc] initWithImage:baseImage];
        [picture addTarget:overlayFilter];
        
        id blending = [self effectByBlendMode:blendingMode];
        [overlayFilter addTarget:blending atTextureLocation:1];
        
        [picture addTarget:blending];
        [picture processImage];
        UIImage* mergedImage = [blending imageFromCurrentlyProcessedOutput];
        [picture removeAllTargets];
        [overlayFilter removeAllTargets];
        return mergedImage;
        
    }else{
        
        GPUImageOpacityFilter* opacityFilter = [[GPUImageOpacityFilter alloc] init];
        opacityFilter.opacity = opacity;
        [overlayFilter addTarget:opacityFilter];
        
        GPUImagePicture* picture = [[GPUImagePicture alloc] initWithImage:baseImage];
        [picture addTarget:overlayFilter];
        
        id blending = [self effectByBlendMode:blendingMode];
        [opacityFilter addTarget:blending atTextureLocation:1];
        
        [picture addTarget:blending];
        [picture processImage];
        UIImage* mergedImage = [blending imageFromCurrentlyProcessedOutput];
        [picture removeAllTargets];
        [overlayFilter removeAllTargets];
        [opacityFilter removeAllTargets];
        return mergedImage;
        
    }
    
}

+ (id)effectByBlendMode:(VnBlendingMode)mode
{
    id blending;
    if(mode == VnBlendingModeNormal){
        blending = [[VnBlendingNormal alloc] init];
    }
    if(mode == VnBlendingModeDarken){
        blending = [[VnBlendingDarken alloc] init];
    }
    if(mode == VnBlendingModeMultiply){
        blending = [[VnBlendingMultiply alloc] init];
    }
    if(mode == VnBlendingModeScreen){
        blending = [[VnBlendingScreen alloc] init];
    }
    if(mode == VnBlendingModeSoftLight){
        blending = [[VnBlendingSoftLight alloc] init];
    }
    if(mode == VnBlendingModeLighten){
        blending = [[VnBlendingLighten alloc] init];
    }
    if(mode == VnBlendingModeHardLight){
        blending = [[VnBlendingHardLight alloc] init];
    }
    if(mode == VnBlendingModeVividLight){
        blending = [[VnBlendingVividLight alloc] init];
    }
    if(mode == VnBlendingModeOverlay){
        blending = [[VnBlendingOverlay alloc] init];
    }
    if(mode == VnBlendingModeColorDodge){
        blending = [[VnBlendingColorDodge alloc] init];
    }
    if(mode == VnBlendingModeLinearDodge){
        blending = [[VnBlendingLinearDodge alloc] init];
    }
    if(mode == VnBlendingModeDarkerColor){
        blending = [[VnBlendingDarkerColor alloc] init];
    }
    if(mode == VnBlendingModeExclusion){
        blending = [[VnBlendingExclusion alloc] init];
    }
    if(mode == VnBlendingModeColor){
        blending = [[VnBlendingColor alloc] init];
    }
    if(mode == VnBlendingModeHue){
        blending = [[VnBlendingHue alloc] init];
    }
    if(mode == VnBlendingModeColorBurn){
        blending = [[VnBlendingColorBurn alloc] init];
    }
    if(mode == VnBlendingModeSaturation){
        blending = [[VnBlendingSaturation alloc] init];
    }
    if(mode == VnBlendingModeLuminotisy){
        blending = [[VnBlendingLuminosity alloc] init];
    }
    if(mode == VnBlendingModeDifference){
        blending = [[VnBlendingDifference alloc] init];
    }
    if(mode == VnBlendingModeLinearLight){
        blending = [[VnBlendingLinearLight alloc] init];
    }
    return blending;
}

@end
