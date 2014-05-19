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
    CGRect frame = CGRectMake(0.0f, 0.0f, [UIScreen width], [RnCurrentSettings navigationBarHeight]);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [RnCurrentSettings navigationBarBgColor];
        
        _titleLabel = [[RnViewLabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
        _titleLabel.fontSize = 20.0f;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

@end
