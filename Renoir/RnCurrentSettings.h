//
//  RnCurrentSettings.h
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RnCurrentSettings : NSObject
+ (RnCurrentSettings*)instance;

+ (float)homeLauncherHeight;
+ (int)homeMaxNumberOfGalleryItem;
+ (CGSize)homeGalleryItemSize;
+ (float)homeGalleryItemPadding;
+ (int)homeNumberOfGalleryItemInOneColumn;

@end
