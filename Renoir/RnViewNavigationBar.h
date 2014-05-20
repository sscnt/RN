//
//  RnViewNavigationBar.h
//  Renoir
//
//  Created by SSC on 2014/05/20.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RnViewLabel.h"
#import "RnViewNavigationBarButton.h"

@protocol RnViewNavigationBarDelegate <NSObject>
- (void)navigationBarDidBackButtonTouchUpInside:(RnViewNavigationBarButton*)button;
- (void)navigationBarDidNextButtonTouchUpInside:(RnViewNavigationBarButton*)button;
@end

@interface RnViewNavigationBar : UIView
{
    RnViewLabel* _titleLabel;
}

@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) RnViewNavigationBarButton* backButton;
@property (nonatomic, strong) RnViewNavigationBarButton* nextButton;
@property (nonatomic, weak) id<RnViewNavigationBarDelegate> delegate;

- (void)showBackButton;
- (void)showNextButton;

- (void)didButtonTouchUpInside:(id)sender;

@end
