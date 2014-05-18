//
//  UnkoViewController.m
//  Renoir
//
//  Created by SSC on 2014/05/15.
//  Copyright (c) 2014年 SSC. All rights reserved.
//

#import "UnkoViewController.h"

@interface UnkoViewController ()

@end

@implementation UnkoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentIndex = 1;
    // Do any additional setup after loading the view.
    
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 100.0f)];
    button.backgroundColor = [UIColor greenColor];
    [button addTarget:self action:@selector(didClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*)processWithImage:(UIImage*)image
{
    GPUImagePicture* pic = [[GPUImagePicture alloc] initWithImage:image];
    RnFilterDryBrush* filter = [[RnFilterDryBrush alloc] init];
    filter.blurRadiusInPixels = 5.0f;
    filter.intensityLevel = 64;
    [pic addTarget:filter];
    [pic processImage];
    [pic removeAllTargets];
    return [filter imageFromCurrentlyProcessedOutput];
}

- (void)drawAtIndex:(int)index
{
    UIImage* image = [self _processWithImage:[RnCurrentImage exploadedOriginalImageAtIndex:index]];
    [RnCurrentImage saveExploadedOriginalImage:image atIndex:index];
}

- (void)draw
{
    if (_currentIndex == 6) {
        _currentIndex = 1;
        return;
    }
    NSLog(@"draw!");
    
    __block UnkoViewController* _self = self;
    __block UIImageView* imgView = nil;
    dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t q_main = dispatch_get_main_queue();
    dispatch_async(q_global, ^{
        @autoreleasepool
        {
            if (_self.currentIndex == 5) {
                
            }else{
                [self drawAtIndex:_self.currentIndex];
            }
            _self.currentIndex++;
        }
        dispatch_async(q_main, ^{
            if (_self.currentIndex == 6) {
                UIImage* image = [RnCurrentImage mergeOriginalImageAndDeleteCache:YES];
                
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                
                imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, 320.0f, image.size.height * 320.0f / image.size.width)];
                imgView.image = image;
                imgView.tag = 1;
                [_self.view addSubview:imgView];
            }
            //[_self performSelector:@selector(draw) withObject:nil afterDelay:3.0f];
            [_self draw];
        });
    });
    
    
}

- (UIImage*)_processWithImage:(UIImage*)image
{
	// CGImageを取得する
	CGImageRef cgImage = image.CGImage;
    
	// 画像情報を取得する
	size_t width = CGImageGetWidth(cgImage);
	size_t height = CGImageGetHeight(cgImage);
	size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
	size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
	size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
	bool shouldInterpolate = CGImageGetShouldInterpolate(cgImage);
	CGColorRenderingIntent intent = CGImageGetRenderingIntent(cgImage);
    
    int index = 0;
    int intensity_count[256] = {0};
    int sumR[256] = {0};
    int sumG[256] = {0};
    int sumB[256] = {0};
    int current_intensity = 0;
    int X,Y, x,y;
    int curMax = 0;
    int maxIndex = 0;
    int RADIUS = 5;
    int radius = RADIUS;
    int N = 0;
    double variance = 0.0;
    double average = 0.0;
    int intensity_level = 64;
    double max_variance = 0.0, min_variance = 1.0;
    UInt8 r, g, b;
    UInt8* pixel;
    
	// データプロバイダを取得する
	CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    CFDataRef tmpData = CGDataProviderCopyData(dataProvider);
    CFDataRef tmpData2 = CGDataProviderCopyData(dataProvider);
    
    //CGDataProviderRelease(dataProvider);
    
    CFMutableDataRef outputData = CFDataCreateMutableCopy(0, 0, tmpData2);
    
    CFRelease(tmpData2);
    
    UInt8 *buffer = (UInt8 *)CFDataGetBytePtr(tmpData);
    UInt8 *pOutBuffer = (UInt8 *)CFDataGetMutableBytePtr(outputData);
    
    int r2 = radius * radius;
    int cr = 0;
    
    
	// ビットマップに効果を与える
	for (Y = RADIUS ; Y < (height - RADIUS); Y++)
	{
		for (X = RADIUS; X < (width - RADIUS); X++)
		{
            memset(&intensity_count[0], 0, sizeof(intensity_count));
            variance = 0.0;
            average = 0.0;
            radius = RADIUS;
            N = 0;
            memset(&sumR[0], 0, sizeof(sumR));
            memset(&sumG[0], 0, sizeof(sumG));
            memset(&sumB[0], 0, sizeof(sumB));
            
			// RGBの値を取得する
            
            /* Calculate the highest intensity Neighbouring Pixels. */
            for(y = -radius; y <= radius; y++) {
                for(x = -radius; x <= radius; x++) {
                    cr = x * x + y * y;
                    if (cr > r2) {
                        continue;
                    }
                    index = ((Y + y) * width * 4) + ((X + x) * 4);
                    pixel = buffer + index;
                    
                    r = *(pixel + 0);
                    g = *(pixel + 1);
                    b = *(pixel + 2);
                    
                    current_intensity = ((r + g + b) * intensity_level/3.0)/255;
                    
                    //NSLog(@"(%d, %d) rgb = %d, %d, %d int = %d", X + x, Y + y, r, g, b, current_intensity);
                    
                    intensity_count[current_intensity]++;
                    sumR[current_intensity] += r;
                    sumG[current_intensity] += g;
                    sumB[current_intensity] += b;
                }
            }
            index = (Y * width * 4) + (X * 4);
            
            maxIndex = 0;
            curMax = intensity_count[maxIndex];
            for( int i = 0; i < intensity_level; i++ ) {
                if( intensity_count[i] > curMax ) {
                    curMax = intensity_count[i];
                    maxIndex = i;
                }
            }
            
            if(curMax > 0) {
                UInt8* tmp = pOutBuffer + index;
                *(tmp + 0) = sumR[maxIndex]/curMax;
                *(tmp + 1) = sumG[maxIndex]/curMax;
                *(tmp + 2) = sumB[maxIndex]/curMax;
                
                //NSLog(@"###(%d, %d) rgb = %d, %d, %d", Y, X, *(tmp), *(tmp+1), *(tmp+2));
                
    
                //pOutBuffer[index + 0] = sumR[maxIndex]/curMax;
                //pOutBuffer[index + 1] = sumG[maxIndex]/curMax;
                //pOutBuffer[index + 2] = sumB[maxIndex]/curMax;
            }
            
		}
    }
    
    NSLog(@"max: %lf", max_variance);
    NSLog(@"min: %lf", min_variance);
    
    CFIndex length = CFDataGetLength(tmpData);
	CFRelease(tmpData);
    
    
	// 効果を与えたデータを作成する
	CFDataRef effectedData = CFDataCreate(NULL, pOutBuffer, length);
    
    
    
	// 効果を与えたデータプロバイダを作成する
	CGDataProviderRef effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
	// 画像を作成する
	CGImageRef effectedCgImage = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpace, bitmapInfo, effectedDataProvider, NULL, shouldInterpolate, intent);
	CGDataProviderRelease(effectedDataProvider);
    
    UIImage* effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
	// 作成したデータを解放する
	CFRelease(effectedData);
	CGImageRelease(effectedCgImage);
    CGColorSpaceRelease(colorSpace);
    CFRelease(outputData);
    
    return effectedImage;
}

#pragma mark  delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    BOOL imageExists = NO;
    
    @autoreleasepool {
        UIImage* imageOriginal = [info objectForKey:UIImagePickerControllerOriginalImage];
        if(imageOriginal){
            imageExists = YES;
            if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
                UIImageWriteToSavedPhotosAlbum(imageOriginal, nil, nil, nil);
            }
            [RnCurrentImage saveOriginalImageIn4Parts:imageOriginal];
        }
    }
    
    if (imageExists) {
        [self performSelector:@selector(draw) withObject:nil afterDelay:0.5f];
        return;
    }
    
    
    __weak UnkoViewController* _self = self;
    NSURL* imageurl = [info objectForKey:UIImagePickerControllerReferenceURL];
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:imageurl
             resultBlock: ^(ALAsset *asset)
     {
         @autoreleasepool {
             ALAssetRepresentation *representation;
             representation = [asset defaultRepresentation];
             UIImage* imageOriginal = [[UIImage alloc] initWithCGImage:representation.fullResolutionImage];
             [RnCurrentImage saveOriginalImageIn4Parts:imageOriginal];
         }
         [self performSelector:@selector(draw) withObject:nil afterDelay:0.5f];
     }
            failureBlock:^(NSError *error)
     {
     }
     ];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)didClick:(id)sender
{
    for (UIView* subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]  ) {
            ((UIImageView*)subview).image = nil;
            [subview removeFromSuperview];
        }
    }
    
    [RnCurrentImage cleanCache];
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    [pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    //pickerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:pickerController animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
