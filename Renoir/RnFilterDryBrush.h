//
//  RnFilterDryBrush.h
//  Renoir
//
//  Created by SSC on 2014/05/17.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "GPUImageTwoPassTextureSamplingFilter.h"

@interface RnFilterDryBrush : GPUImageTwoPassTextureSamplingFilter
{
    BOOL shouldResizeBlurRadiusWithImageSize;
    CGFloat _blurRadiusInPixels;
    int _intensityLevel;
}

/** A multiplier for the spacing between texels, ranging from 0.0 on up, with a default of 1.0. Adjusting this may slightly increase the blur strength, but will introduce artifacts in the result.
 */
@property (readwrite, nonatomic) CGFloat texelSpacingMultiplier;

/** A radius in pixels to use for the blur, with a default of 2.0. This adjusts the sigma variable in the Gaussian distribution function.
 */
@property (readwrite, nonatomic) CGFloat blurRadiusInPixels;

/** Setting these properties will allow the blur radius to scale with the size of the image
 */
@property (readwrite, nonatomic) CGFloat blurRadiusAsFractionOfImageWidth;
@property (readwrite, nonatomic) CGFloat blurRadiusAsFractionOfImageHeight;

/// The number of times to sequentially blur the incoming image. The more passes, the slower the filter.
@property(readwrite, nonatomic) NSUInteger blurPasses;

@property (nonatomic, assign) int intensityLevel;

+ (NSString *)vertexShaderForStandardBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
+ (NSString *)vertexShaderForOptimizedBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma;
+ (NSString *)fragmentShaderForOptimizedBlurOfRadius:(NSUInteger)blurRadius sigma:(CGFloat)sigma intensityLevel:(int)intensityLevel;

- (void)switchToVertexShader:(NSString *)newVertexShader fragmentShader:(NSString *)newFragmentShader;

@end
