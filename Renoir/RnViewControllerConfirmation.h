//
//  RnViewControllerPreview.h
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "RnViewNavigationBar.h"
#import "RnViewControllerFrame.h"

@interface RnViewControllerConfirmation : UIViewController <RnViewNavigationBarDelegate>

@property (nonatomic, strong) ALAsset* asset;
@property (nonatomic, strong) RnViewNavigationBar* navigationBar;
@property (nonatomic, strong) UIImageView* imgView;

@end
