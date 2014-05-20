//
//  RnViewNavigationBarButton.m
//  Renoir
//
//  Created by SSC on 2014/05/20.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewNavigationBarButton.h"

@implementation RnViewNavigationBarButton

- (id)initWithType:(RnViewNavigationBarButtonType)type
{
    CGRect frame;
    switch (type) {
        case RnViewNavigationBarButtonTypeBack:
            frame = CGRectMake(0.0f, 0.0f, [RnCurrentSettings navigationBarHeight], [RnCurrentSettings navigationBarHeight]);
            break;
        case RnViewNavigationBarButtonTypeNext:
        {
            RnViewLabel* label = [[RnViewLabel alloc] initWithFrame:CGRectZero];
            label.text = NSLocalizedString(@"NEXT", nil);
            label.fontSize = 18.0f;
            [label sizeToFit];
            frame = CGRectMake(0.0f, 0.0f, label.frame.size.width, [RnCurrentSettings navigationBarHeight]);
        }
            break;
    }
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _type = type;
        
        if (type == RnViewNavigationBarButtonTypeNext) {
            RnViewLabel* label = [[RnViewLabel alloc] initWithFrame:frame];
            label.text = NSLocalizedString(@"NEXT", nil);
            label.fontSize = 18.0f;
            label.textColor = [RnCurrentSettings navigationBarButtonLightColor];
            [self addSubview:label];
        }
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //// Color Declarations
    UIColor* color = [UIColor whiteColor];
    
    switch (_type) {
        case RnViewNavigationBarButtonTypeBack:
        {
            //// Bezier 2 Drawing
            UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
            [bezier2Path moveToPoint: CGPointMake(27.12, 18.64)];
            [bezier2Path addLineToPoint: CGPointMake(22.26, 23.5)];
            [bezier2Path addLineToPoint: CGPointMake(34, 23.5)];
            [bezier2Path addLineToPoint: CGPointMake(34, 26.5)];
            [bezier2Path addLineToPoint: CGPointMake(22.26, 26.5)];
            [bezier2Path addLineToPoint: CGPointMake(27.12, 31.36)];
            [bezier2Path addLineToPoint: CGPointMake(25, 33.49)];
            [bezier2Path addLineToPoint: CGPointMake(16.51, 25)];
            [bezier2Path addLineToPoint: CGPointMake(25, 16.51)];
            [bezier2Path addLineToPoint: CGPointMake(27.12, 18.64)];
            [bezier2Path closePath];
            [color setFill];
            [bezier2Path fill];

        }
            break;
            
        default:
            break;
    }
}

@end
