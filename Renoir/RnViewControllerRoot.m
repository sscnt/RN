//
//  RnViewControllerRoot.m
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewControllerRoot.h"

@implementation RnViewControllerRoot

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationBar setHidden:YES];
    self.delegate = self;
    RnViewControllerHome* controller = [[RnViewControllerHome alloc] init];
    [self pushViewController:controller animated:NO];

}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //スワイプによる戻るを無効にする(スワイプを少しして戻すとNavigationBarが存在しなくなる事象回避)
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end