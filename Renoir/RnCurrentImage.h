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
@property (nonatomic, strong) NSMutableDictionary* cache;

+ (RnCurrentImage*)instance;
+ (BOOL)imageExistsAtPath:(NSString*)path;
+ (UIImage*)imageAtPath:(NSString*)path;
+ (BOOL)saveImage:(UIImage*)image AtPath:(NSString*)path;
+ (BOOL)writeImage:(UIImage*)image AtPath:(NSString*)path;
+ (BOOL)deleteImageAtPath:(NSString*)path;
+ (void)writeCacheToFile;
+ (void)cleanCache;
+ (void)clean;

+ (void)saveOriginalImageIn4Parts:(UIImage*)image;
+ (void)saveExploadedOriginalImage:(UIImage*)image atIndex:(int)index;
+ (BOOL)deleteExploadedOriginalImageAtIndex:(int)index;
+ (UIImage*)mergeOriginalImageAndDeleteCache:(BOOL)del;
+ (UIImage*)exploadedOriginalImageAtIndex:(int)index;

@end
