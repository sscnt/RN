//
//  RnProcessor.h
//  Renoir
//
//  Created by SSC on 2014/05/20.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@protocol RnProcessorDelegate <NSObject>
- (void)processorCurrentProgress:(float)progress;
@end

@interface RnProcessor : NSObject

@property (nonatomic, assign) int radius;
@property (nonatomic, weak) id<RnProcessorDelegate> delegate;

+ (RnProcessor*)instance;

+ (void)setRadius:(int)radius;
+ (void)updateCurrentProgress:(float)progress;

+ (UIImage*)executeWithImage:(UIImage*)image;
+ (UIImage*)applyDryBrushToImage:(UIImage*)image;

+ (UIImage*)mergeBaseImage:(UIImage*)baseImage overlayImage:(UIImage*)overlayImage opacity:(CGFloat)opacity blendingMode:(VnBlendingMode)blendingMode;
+ (UIImage*)mergeBaseImage:(UIImage*)baseImage overlayFilter:(GPUImageFilter*)overlayFilter opacity:(CGFloat)opacity blendingMode:(VnBlendingMode)blendingMode;
+ (id)effectByBlendMode:(VnBlendingMode)mode;

@end
