//
//  RnViewNavigationBar.m
//  Renoir
//
//  Created by SSC on 2014/05/20.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewNavigationBar.h"

@implementation RnViewNavigationBar

- (id)init
{
    CGRect frame = CGRectMake(0.0f, 0.0f, [UIScreen width], 50.0f);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [RnCurrentSettings navigationBarBgColor];
    }
    return self;
}

@end
