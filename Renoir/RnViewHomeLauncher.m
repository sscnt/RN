//
//  RnViewHomeLauncher.m
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewHomeLauncher.h"

@implementation RnViewHomeLauncher

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [RnCurrentSettings homeLauncherBgColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
