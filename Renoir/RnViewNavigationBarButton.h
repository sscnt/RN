//
//  RnViewNavigationBarButton.h
//  Renoir
//
//  Created by SSC on 2014/05/20.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RnViewNavigationBarButtonType){
    RnViewNavigationBarButtonTypeBack = 1,
    RnViewNavigationBarButtonTypeNext
};

@interface RnViewNavigationBarButton : UIButton

- (id)initWithType:(RnViewNavigationBarButtonType)type;

@end
