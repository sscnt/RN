//
//  AppDelegate.h
//  Renoir
//
//  Created by SSC on 2014/05/15.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RnViewControllerHome;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, weak) RnViewControllerHome* controller;

@end
