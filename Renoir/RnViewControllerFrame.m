//
//  RnViewControllerFrame.m
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewControllerFrame.h"

@implementation RnViewControllerFrame

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [RnCurrentSettings viewControllerBgColor];
    _navigationBar = [[RnViewNavigationBar alloc] init];
    _navigationBar.title = NSLocalizedString(@"FRAME", nil);
    _navigationBar.delegate = self;
    [self.view addSubview:_navigationBar];

}

- (void)navigationBarDidBackButtonTouchUpInside:(RnViewNavigationBarButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationBarDidNextButtonTouchUpInside:(RnViewNavigationBarButton *)button
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
