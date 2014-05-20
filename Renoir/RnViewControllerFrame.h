//
//  RnViewControllerFrame.h
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RnViewNavigationBar.h"

@interface RnViewControllerFrame : UIViewController <RnViewNavigationBarDelegate>

@property (nonatomic, strong) RnViewNavigationBar* navigationBar;
@property (nonatomic, weak) UIImage* imageToProcess;

@end
