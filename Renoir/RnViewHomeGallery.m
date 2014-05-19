//
//  RnViewHomeGallery.m
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewHomeGallery.h"

@implementation RnViewHomeGallery

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        
        _insertY = [RnCurrentSettings homeGalleryItemPadding];
        _insertX = [RnCurrentSettings homeGalleryItemPadding];
        _currentColumn = 1;
    }
    return self;
}

- (void)addAsset:(ALAsset *)asset
{
    float padding = [RnCurrentSettings homeGalleryItemPadding];
    float width = [RnCurrentSettings homeGalleryItemSize].width;
    float height = [RnCurrentSettings homeGalleryItemSize].height;
    
    if (_currentColumn > [RnCurrentSettings homeNumberOfGalleryItemInOneColumn]) {
        _insertX = padding;
        _insertY += padding + height;
        _scrollView.contentSize = CGSizeMake([self width], _insertY + height + padding);
        _currentColumn = 1;
    }
    
    RnViewHomeGalleryItemButton* button = [[RnViewHomeGalleryItemButton alloc] initWithFrame:CGRectMake(_insertX, _insertY, width, height)];
    button.asset = asset;
    [_scrollView addSubview:button];
    
    _currentColumn++;
    _insertX += padding + width;
    
}
- (void)scrolltoBottom
{
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:NO];
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
