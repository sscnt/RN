//
//  RnViewControllerHome.m
//  Renoir
//
//  Created by SSC on 2014/05/19.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "RnViewControllerHome.h"

@interface RnViewControllerHome ()

@end

@implementation RnViewControllerHome

- (void)viewDidLoad
{
    [super viewDidLoad];
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    [appdelegate setController:self];    
    
    self.view.backgroundColor = [RnCurrentSettings viewControllerBgColor];
    
    float height = [RnCurrentSettings homeLauncherHeight];
    _launcherView = [[RnViewHomeLauncher alloc] initWithFrame:CGRectMake(0.0f, [UIScreen height] - height, [UIScreen width], height)];
    [self.view addSubview:_launcherView];
    
    [self initGallery];
}

- (void)removeGallery
{
    [_galleryView removeFromSuperview];
    _galleryView.delegate = nil;
    _galleryView = nil;
}

- (void)initGallery
{
    LOG(@"init gallery");
    if (_galleryView) {
        [self removeGallery];
    }
    
    float height = [UIScreen height] - [RnCurrentSettings homeLauncherHeight];
    _galleryView = [[RnViewHomeGallery alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen width], height)];
    _galleryView.delegate = self;
    [self.view addSubview:_galleryView];
    
    
    __block RnViewHomeGallery* _g = _galleryView;
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        self.library = [[ALAssetsLibrary alloc] init];
    });
    
    [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup* group, BOOL* stop){
        
        int numberOfAssets = (int)[group numberOfAssets];
        int numberToDisplay = numberOfAssets;
        if (numberToDisplay > [RnCurrentSettings homeMaxNumberOfGalleryItem]) {
            numberToDisplay = [RnCurrentSettings homeMaxNumberOfGalleryItem];
        }else{
            int rest = numberToDisplay / 4;
            numberToDisplay = rest * 4;
        }
        [_g setMaxNumberOfItems:numberToDisplay];
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        for (int i = numberOfAssets - numberToDisplay; i < numberOfAssets; i++) {
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:0 usingBlock:^(ALAsset* asset, NSUInteger index, BOOL* stop) {
                if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                    [_g addAsset:asset];
                }
            }];
        }
        [_g scrolltoBottom];
        
    } failureBlock:^(NSError* error){
        
    }];
}

- (void)galleryDidSelectAsset:(ALAsset *)asset
{    
    RnViewControllerConfirmation* controller = [[RnViewControllerConfirmation alloc] init];
    controller.asset = asset;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
