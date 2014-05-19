//
//  RnViewControllerPreview.m
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewControllerConfirmation.h"

@implementation RnViewControllerConfirmation

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [RnCurrentSettings viewControllerBgColor];
    _navigationBar = [[RnViewNavigationBar alloc] init];
    _navigationBar.title = NSLocalizedString(@"PREVIEW", nil);
    [self.view addSubview:_navigationBar];
    
    CGRect frame;
    ALAssetRepresentation *representation = [_asset defaultRepresentation];
    UIImage *image = [[UIImage alloc] initWithCGImage:[representation fullScreenImage]
                                       scale:[representation scale]
                                 orientation:[representation orientation]];
    
    float width, height;
    if ([UIDevice isiPad]) {
        
    }else{
        if (image.size.width > image.size.height) {
            width = [UIScreen width];
            height = image.size.height * width / image.size.width;
        }else{
            height = [UIScreen width];
            width = image.size.width * height / image.size.height;
        }
    }
    frame = CGRectMake(0.0f, 0.0f, width, height);
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:frame];
    imgView.center = self.view.center;
    imgView.image = image;
    [self.view addSubview:imgView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
