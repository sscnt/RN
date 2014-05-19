//
//  RnViewHomeGalleryItemButton.m
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewHomeGalleryItemButton.h"

@implementation RnViewHomeGalleryItemButton

- (void)setAsset:(ALAsset *)asset
{
    _asset = asset;
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:self.bounds];
    imgView.image = [[UIImage alloc] initWithCGImage:[asset thumbnail]];
    [self addSubview:imgView];
    
}

@end
