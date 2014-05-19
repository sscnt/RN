//
//  RnViewNavigationBar.h
//  Renoir
//
//  Created by SSC on 2014/05/20.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RnViewLabel.h"
#import "RnViewHomeGalleryItemButton.h"

@interface RnViewNavigationBar : UIView
{
    RnViewLabel* _titleLabel;
}

@property (nonatomic, strong) NSString* title;

- (void)showBackButton;
- (void)showNextButton;

@end
