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
        _titleLabel.fontSize = 18.0f;
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)showBackButton
{
    if (_backButton) {
        [_backButton removeFromSuperview];
        _backButton = nil;
    }
    _backButton = [[RnViewNavigationBarButton alloc] initWithType:RnViewNavigationBarButtonTypeBack];
    [_backButton addTarget:self action:@selector(didButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
}

- (void)showNextButton
{
    if (_nextButton) {
        [_nextButton removeFromSuperview];
        _nextButton = nil;
    }
    _nextButton = [[RnViewNavigationBarButton alloc] initWithType:RnViewNavigationBarButtonTypeNext];
    [_nextButton addTarget:self action:@selector(didButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    float x = [self width] - [_nextButton width] - 16.0f;
    [_nextButton setX:x];
    [self addSubview:_nextButton];
}

- (void)didButtonTouchUpInside:(id)sender
{
    if (sender == _backButton) {
        [self.delegate navigationBarDidBackButtonTouchUpInside:sender];
        return;
    }
    if (sender == _nextButton) {
        [self.delegate navigationBarDidNextButtonTouchUpInside:sender];
        return;
    }
}

@end
