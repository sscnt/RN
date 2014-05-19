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
    RnViewControllerHome* controller = [[RnViewControllerHome alloc] init];
    [self pushViewController:controller animated:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end