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

#pragma mark home

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