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
        _scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_scrollView];
        
        _insertY = 0.0f;
        _insertX = 0.0f;
    }
    return self;
}

- (void)setMaxNumberOfItems:(int)maxNumberOfItems
{
    int column = [RnCurrentSettings homeNumberOfGalleryItemInOneColumn];
    _maxNumberOfItems = maxNumberOfItems;
    float height = (float)(maxNumberOfItems / column) * [RnCurrentSettings homeGalleryItemSize].height + [RnCurrentSettings homeGalleryItemPadding] * (float)(maxNumberOfItems / column + 1);
    _scrollView.contentSize = CGSizeMake(self.frame.size.width, height);
}

- (void)addAsset:(ALAsset *)asset
{
    float padding = [RnCurrentSettings homeGalleryItemPadding];
    float width = [RnCurrentSettings homeGalleryItemSize].width;
    float height = [RnCurrentSettings homeGalleryItemSize].height;
    
    RnViewHomeGalleryItemButton* button = [[RnViewHomeGalleryItemButton alloc] initWithFrame:CGRectMake(_insertX, _insertY, width, height)];
    button.asset = asset;
    [_scrollView addSubview:button];
    
    _insertX += padding + width;
    if (_insertX > _scrollView.contentSize.width) {
        _insertX = 0.0f;
        _insertY += padding + height;
    }
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
