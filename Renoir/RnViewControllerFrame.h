//
//  RnViewControllerFrame.h
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RnViewNavigationBar.h"

@interface RnViewControllerFrame : UIViewController <RnViewNavigationBarDelegate, RnProcessorDelegate>

@property (nonatomic, strong) RnViewNavigationBar* navigationBar;
@property (nonatomic, weak) UIImage* imageToProcess;
@property (nonatomic, strong) UIImageView* imgView;

- (void)finishProcessing;

@end
