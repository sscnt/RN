//
//  RnCurrentImage.h
//  Renoir
//
//  Created by SSC on 2014/05/17.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RnCurrentImage : NSObject

@property (nonatomic, assign) CGSize originalImageSize;

+ (RnCurrentImage*)instance;
+ (BOOL)imageExistsAtPath:(NSString*)path;
+ (UIImage*)imageAtPath:(NSString*)path;
+ (BOOL)saveImage:(UIImage*)image AtPath:(NSString*)path;
+ (BOOL)writeImage:(UIImage*)image AtPath:(NSString*)path;
+ (BOOL)deleteImageAtPath:(NSString*)path;
+ (void)clean;

+ (void)saveOriginalImageIn4Parts:(UIImage*)image;

@end
