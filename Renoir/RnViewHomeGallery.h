//
//  RnViewHomeGallery.h
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RnViewHomeGalleryItemButton.h"

@interface RnViewHomeGallery : UIView
{
    float _insertY;
    float _insertX;
}

@property (nonatomic, assign) int maxNumberOfItems;
@property (nonatomic, strong) UIScrollView* scrollView;

- (void)addAsset:(ALAsset*)asset;
- (void)didButtonTouchUpInside:(RnViewHomeGalleryItemButton*)button;
- (void)scrolltoBottom;

@end
