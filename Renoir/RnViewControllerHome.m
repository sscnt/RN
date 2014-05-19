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
    self.view.backgroundColor = [UIColor colorWithRed:243.0f/255.0f green:241.0f/255.0f blue:226.0f/255.0f alpha:1.0f];
    
    float height = [RnCurrentSettings homeLauncherHeight];
    _launcherView = [[RnViewHomeLauncher alloc] initWithFrame:CGRectMake(0.0f, [UIScreen height] - height, [UIScreen width], height)];
    [self.view addSubview:_launcherView];
    
    [self initGallery];
}

- (void)initGallery
{
    if (_galleryView) {
        _galleryView = nil;
    }
    
    float height = [UIScreen height] - [RnCurrentSettings homeLauncherHeight];
    _galleryView = [[RnViewHomeGallery alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen width], height)];
    [self.view addSubview:_galleryView];
    
    
    __block RnViewHomeGallery* _g = _galleryView;
    
    ALAssetsLibrary* al = [[ALAssetsLibrary alloc] init];
    [al enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup* group, BOOL* stop){
        
        int numberOfAssets = (int)[group numberOfAssets];
        int numberToDisplay = numberOfAssets;
        if (numberToDisplay > [RnCurrentSettings homeMaxNumberOfGalleryItem]) {
            numberToDisplay = [RnCurrentSettings homeMaxNumberOfGalleryItem];
        }else{
            int rest = numberToDisplay / 4;
            numberToDisplay = rest * 4;
        }
        [_g setMaxNumberOfItems:numberToDisplay];
        
        for (int i = numberOfAssets - numberToDisplay - 1; i < numberOfAssets; i++) {
            [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:0 usingBlock:^(ALAsset* asset, NSUInteger index, BOOL* stop) {
                [_g addAsset:asset];
            }];
        }
        
        
    } failureBlock:^(NSError* error){
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
