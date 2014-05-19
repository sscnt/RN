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

@protocol RnViewHomeGalleryDelegate <NSObject>
- (void)galleryDidSelectAsset:(ALAsset*)asset;
@end

@interface RnViewHomeGallery : UIView
{
    float _insertY;
    float _insertX;
    int _currentColumn;
}

@property (nonatomic, assign) int maxNumberOfItems;
@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, weak) id<RnViewHomeGalleryDelegate> delegate;

- (void)addAsset:(ALAsset*)asset;
- (void)didButtonTouchUpInside:(RnViewHomeGalleryItemButton*)button;
- (void)scrolltoBottom;

@end
