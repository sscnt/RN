//
//  RnViewControllerHome.h
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "RnViewHomeLauncher.h"
#import "RnViewHomeGallery.h"
#import "RnViewControllerConfirmation.h"

@interface RnViewControllerHome : UIViewController <RnViewHomeGalleryDelegate>
{
    BOOL isBackground;
}

@property (nonatomic, strong) RnViewHomeLauncher* launcherView;
@property (nonatomic, strong) RnViewHomeGallery* galleryView;
@property (nonatomic, strong) ALAssetsLibrary* library;

- (void)initGallery;
- (void)removeGallery;

@end
