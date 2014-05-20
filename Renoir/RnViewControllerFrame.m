//
//  RnViewControllerFrame.m
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewControllerFrame.h"

@implementation RnViewControllerFrame

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [RnCurrentSettings viewControllerBgColor];
    _navigationBar = [[RnViewNavigationBar alloc] init];
    _navigationBar.title = NSLocalizedString(@"FRAME", nil);
    _navigationBar.delegate = self;
    [self.view addSubview:_navigationBar];
    
    RnProcessor* rp = [RnProcessor instance];
    rp.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    __block RnViewControllerFrame* _self = self;
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    dispatch_async(q_global, ^{
        @autoreleasepool
        {
            UIImage* image = _self.imageToProcess;
            [RnCurrentImage saveOriginalImageIn4Parts:image];
            
            //// Preview
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
            
            width *= 2.0f;
            height *= 2.0f;
            

            UIImage* previewImage = [image resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationHigh];
            [RnCurrentImage savePreviewOriginalImage:previewImage];
            
            [RnProcessor setRadius:3];
            previewImage = [RnProcessor executeWithImage:previewImage];
            
            [RnCurrentImage savePreviewOriginalImage:previewImage];

        }
        dispatch_async(q_main, ^{
            [_self finishProcessing];
        });
    });
}

- (void)finishProcessing
{
    [_navigationBar showBackButton];
    [_navigationBar showNextButton];
    
    UIImage* image = [RnCurrentImage previewOriginalImage];
    
    CGRect frame = CGRectMake(0.0f, 0.0f, image.size.width / 2.0f, image.size.height / 2.0f);
    _imgView = [[UIImageView alloc] initWithFrame:frame];
    _imgView.center = self.view.center;
    _imgView.image = image;

    [self.view addSubview:_imgView];
}

- (void)processorCurrentProgress:(float)progress
{
    LOG(@"%f", progress);
}

- (void)navigationBarDidBackButtonTouchUpInside:(RnViewNavigationBarButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationBarDidNextButtonTouchUpInside:(RnViewNavigationBarButton *)button
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
