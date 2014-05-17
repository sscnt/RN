//
//  RnCurrentImage.m
//  Renoir
//
//  Created by SSC on 2014/05/17.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnCurrentImage.h"

@implementation RnCurrentImage

#pragma mark init

static RnCurrentImage* sharedRnCurrentImage = nil;

NSString* const pathForOriginalImage = @"tmp/original_image";

+ (RnCurrentImage*)instance {
	@synchronized(self) {
		if (sharedRnCurrentImage == nil) {
			sharedRnCurrentImage = [[self alloc] init];
		}
	}
	return sharedRnCurrentImage;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedRnCurrentImage == nil) {
			sharedRnCurrentImage = [super allocWithZone:zone];
			return sharedRnCurrentImage;
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
        _cache = [NSMutableDictionary dictionary];        
    }
    return self;
}

#pragma mark util

+ (UIImage*)imageAtPath:(NSString *)path
{
    //// Search cache
    UIImage* image = [[self instance].cache objectForKey:[NSString stringWithFormat:@"%@", path]];
    if (image) {
        return image;
    }

    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if( [filemgr fileExistsAtPath:filePath] ){
        UIImage *img = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:fileURL]];
        return img;
    }
    
    LOG(@"Image not found at %@.", path);
    
    return nil;
}

+ (BOOL)saveImage:(UIImage *)image AtPath:(NSString *)path
{
    if (image.imageOrientation != UIImageOrientationUp) {
        image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationUp];
    }
    if (image) {
        [[self instance].cache removeObjectForKey:[NSString stringWithFormat:@"%@", path]];
        [[self instance].cache setObject:image forKey:[NSString stringWithFormat:@"%@", path]];
    }
    return YES;
}

+ (BOOL)writeImage:(UIImage *)image AtPath:(NSString *)path
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.99);
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    BOOL success = [imageData writeToFile:filePath atomically:YES];
    imageData = nil;
    return success;
}

+ (BOOL)deleteImageAtPath:(NSString *)path
{
    [[self instance].cache removeObjectForKey:path];
    
    path = [NSHomeDirectory() stringByAppendingPathComponent:path];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    NSURL *pathurl = [NSURL fileURLWithPath:path];
    if( [filemgr fileExistsAtPath:path] ){
        LOG(@"deleting the image at %@" ,path);
        return [filemgr removeItemAtURL:pathurl error:nil];
    }
    return YES;
}

+ (BOOL)imageExistsAtPath:(NSString *)path
{
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:path];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    if( [filemgr fileExistsAtPath:filePath] ){
        return YES;
    }
    return NO;
}

+ (void)writeCacheToFile
{
    for (NSString* path in [[self instance].cache allKeys]) {
        [self writeImage:[[self instance].cache objectForKey:path] AtPath:path];
    }
}

+ (void)cleanCache
{
    [[self instance].cache removeAllObjects];
}

#pragma mark api

+ (void)saveOriginalImageIn4Parts:(UIImage *)image
{
    if ([image maxLength] < 100.0f) {
        return;
    }
    [self instance].originalImageSize = image.size;
    float padding = 3.0 * image.size.width / 1280.0f;
    float cropWidth = floor(image.size.width / 2.0f);
    float cropHeight = floor(image.size.height / 2.0f);
    float restWidth = image.size.width - (cropWidth - padding);
    float restHeight = image.size.height - (cropHeight - padding);
    
    //// 1
    @autoreleasepool {
        UIImage* piece = [image croppedImage:CGRectMake(0.0f, 0.0f, cropWidth + padding, cropHeight + padding)];
        [self saveExploadedOriginalImage:piece atIndex:1];
    }
    //// 2
    @autoreleasepool {
        UIImage* piece = [image croppedImage:CGRectMake(cropWidth - padding, 0.0f, restWidth, cropHeight + padding)];
        [self saveExploadedOriginalImage:piece atIndex:2];
    }
    //// 3
    @autoreleasepool {
        UIImage* piece = [image croppedImage:CGRectMake(0.0f, cropHeight - padding, cropWidth + padding, restHeight)];
        [self saveExploadedOriginalImage:piece atIndex:3];
    }
    //// 4
    @autoreleasepool {
        UIImage* piece = [image croppedImage:CGRectMake(cropWidth - padding, cropHeight - padding, restWidth, restHeight)];
        [self saveExploadedOriginalImage:piece atIndex:4];
    }
}

+ (void)saveExploadedOriginalImage:(UIImage *)image atIndex:(int)index
{
    [self saveImage:image AtPath:[NSString stringWithFormat:@"%@_%d", pathForOriginalImage, index]];
}

+ (UIImage *)exploadedOriginalImageAtIndex:(int)index
{
    return [self imageAtPath:[NSString stringWithFormat:@"%@_%d", pathForOriginalImage, index]];
}

+ (BOOL)deleteExploadedOriginalImageAtIndex:(int)index
{
    return [self deleteImageAtPath:[NSString stringWithFormat:@"%@_%d", pathForOriginalImage, index]];
}

+ (UIImage *)mergeOriginalImageAndDeleteCache:(BOOL)del
{
    CGSize size = [self instance].originalImageSize;
    UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
    
    float padding = 3.0 * size.width / 1280.0f;
    float cropWidth = floor(size.width / 2.0f);
    float cropHeight = floor(size.height / 2.0f);
    float restCropWidth = size.width - (cropWidth - padding);
    float restCropHeight = size.height - (cropHeight - padding);
    float restWidth = size.width - cropWidth;
    float restHeight = size.height - cropHeight;
    
    //// 1
    @autoreleasepool {
        [[self exploadedOriginalImageAtIndex:1] drawAtPoint:CGPointMake(0.0f, 0.0f)];
        if (del) {
            [self deleteExploadedOriginalImageAtIndex:1];
        }
    }
    //// 2
    @autoreleasepool {
        [[[self exploadedOriginalImageAtIndex:2] croppedImage:CGRectMake(padding, 0.0f, restWidth, cropHeight)] drawAtPoint:CGPointMake(cropWidth, 0.0f)];
        if (del) {
            [self deleteExploadedOriginalImageAtIndex:2];
        }
    }
    //// 3
    @autoreleasepool {
        [[[self exploadedOriginalImageAtIndex:3] croppedImage:CGRectMake(0.0f, padding, cropWidth, restHeight)] drawAtPoint:CGPointMake(0.0f, cropHeight)];
        if (del) {
            [self deleteExploadedOriginalImageAtIndex:3];
        }
    }
    //// 4
    @autoreleasepool {
        [[[self exploadedOriginalImageAtIndex:4] croppedImage:CGRectMake(padding, padding, restWidth, restHeight)] drawAtPoint:CGPointMake(cropWidth, cropHeight)];
        if (del) {
            [self deleteExploadedOriginalImageAtIndex:4];
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (void)clean
{
    [self cleanCache];
}

@end
