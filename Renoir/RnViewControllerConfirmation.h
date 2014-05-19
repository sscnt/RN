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

@interface RnViewControllerConfirmation : UIViewController

@property (nonatomic, strong) ALAsset* asset;
@property (nonatomic, strong) RnViewNavigationBar* navigationBar;

@end
