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
        
    }
    return self;
}

#pragma mark util

+ (UIImage*)imageAtPath:(NSString *)path
{
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

#pragma mark api

+ (void)saveOriginalImageIn4Parts:(UIImage *)image
{
    if ([image maxLength] < 100.0f) {
        return;
    }
    NSString* path = pathForOriginalImage;
    float padding = 3.0 * [image maxLength] / 1280.0f;
    float cropWidth = floor(image.size.width / 2.0f);
    float cropHeight = floor(image.size.height / 2.0f);
    float restWidth = image.size.width - (cropWidth - padding);
    float restHeight = image.size.height - (cropHeight - padding);
    
    //// 1
    @autoreleasepool {
        UIImage* piece = [image croppedImage:CGRectMake(0.0f, 0.0f, cropWidth + padding, cropHeight + padding)];
        [self writeImage:piece AtPath:[NSString stringWithFormat:@"%@_%d", path, 1]];
    }
    //// 2
    @autoreleasepool {
        UIImage* piece = [image croppedImage:CGRectMake(cropWidth - padding, 0.0f, restWidth, cropHeight + padding)];
        [self writeImage:piece AtPath:[NSString stringWithFormat:@"%@_%d", path, 1]];
    }
    //// 3
    @autoreleasepool {
        UIImage* piece = [image croppedImage:CGRectMake(0.0f, cropHeight - padding, cropWidth + padding, restHeight)];
        [self writeImage:piece AtPath:[NSString stringWithFormat:@"%@_%d", path, 1]];
    }
    //// 4
    @autoreleasepool {
        UIImage* piece = [image croppedImage:CGRectMake(cropWidth - padding, cropHeight - padding, restWidth, restHeight)];
        [self writeImage:piece AtPath:[NSString stringWithFormat:@"%@_%d", path, 1]];
    }
}


+ (void)clean
{

}

@end
