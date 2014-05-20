//
//  RnCurrentSettings.m
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnCurrentSettings.h"

@implementation RnCurrentSettings

static RnCurrentSettings* sharedRnCurrentSettings = nil;

+ (RnCurrentSettings*)instance {
	@synchronized(self) {
		if (sharedRnCurrentSettings == nil) {
			sharedRnCurrentSettings = [[self alloc] init];
		}
	}
	return sharedRnCurrentSettings;
}

+ (id)allocWithZone:(NSZone *)zone {
	@synchronized(self) {
		if (sharedRnCurrentSettings == nil) {
			sharedRnCurrentSettings = [super allocWithZone:zone];
			return sharedRnCurrentSettings;
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

#pragma mark common

+ (UIColor *)viewControllerBgColor
{
    return [UIColor colorWithRed:40.0f/255.0f green:42.0f/255.0f blue:41.0f/255.0f alpha:1.0f];
}

+ (UIColor *)navigationBarBgColor
{
    return [UIColor colorWithRed:50.0f/255.0f green:52.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
}

+ (UIColor *)navigationBarButtonColor
{
    return [UIColor colorWithWhite:1.0f alpha:1.0f];
}

+ (UIColor *)navigationBarButtonLightColor
{
    return [UIColor colorWithRed:104.0f/255.0f green:211.0f/255.0f blue:231.0f/255.0f alpha:1.0f];
}

+ (float)navigationBarHeight
{
    return 50.0f;
}

#pragma mark home

+ (UIColor *)homeLauncherBgColor
{
    return [self navigationBarBgColor];
}

+ (float)homeLauncherHeight
{
    return 88.0f;
}

+ (int)homeMaxNumberOfGalleryItem
{
    return 200;
}

+ (float)homeGalleryItemPadding
{
    return 2.0f;
}

+ (int)homeNumberOfGalleryItemInOneColumn
{
    if ([UIDevice isiPad]) {
        
    }
    return 4;
}

+ (CGSize)homeGalleryItemSize
{
    float padding = [self homeGalleryItemPadding];
    float column = (float)[self homeNumberOfGalleryItemInOneColumn];
    float length = ([UIScreen width] - padding * (column + 1.0f)) / 4.0f;
    return CGSizeMake(length, length);
}

@end
