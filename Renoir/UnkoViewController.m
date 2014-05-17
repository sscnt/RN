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

- (void)processWithImage:(UIImage*)image
{
    GPUImagePicture* pic = [[GPUImagePicture alloc] initWithImage:image];
    RnFilterDryBrush* filter = [[RnFilterDryBrush alloc] init];
    filter.blurRadiusInPixels = 10.0f;
    filter.intensityLevel = 64;
    [pic addTarget:filter];
    [pic processImage];
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, 320.0f, image.size.height * 320.0f / image.size.width)];
    imgView.image = [filter imageFromCurrentlyProcessedOutput];
    [self.view addSubview:imgView];
}

- (void)_processWithImage:(UIImage*)image
{
    
	// CGImageを取得する
	CGImageRef cgImage;
	cgImage = image.CGImage;
    
	// 画像情報を取得する
	size_t width;
	size_t height;
	size_t bitsPerComponent;
	size_t bitsPerPixel;
	size_t bytesPerRow;
	CGColorSpaceRef colorSpace;
	CGBitmapInfo bitmapInfo;
	bool shouldInterpolate;
	CGColorRenderingIntent intent;
	width = CGImageGetWidth(cgImage);
	height = CGImageGetHeight(cgImage);
	bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
	bitsPerPixel = CGImageGetBitsPerPixel(cgImage);
	bytesPerRow = CGImageGetBytesPerRow(cgImage);
	colorSpace = CGImageGetColorSpace(cgImage);
	bitmapInfo = CGImageGetBitmapInfo(cgImage);
	shouldInterpolate = CGImageGetShouldInterpolate(cgImage);
	intent = CGImageGetRenderingIntent(cgImage);
    
    int index = 0;
    int intensity_count[256] = {0};
    int sumR[256] = {0};
    int sumG[256] = {0};
    int sumB[256] = {0};
    int current_intensity = 0;
    int X,Y, x,y;
    int curMax = 0;
    int maxIndex = 0;
    int RADIUS = 8;
    int fractal_radius = RADIUS;
    int radius = 0;
    int N = 0;
    int fractal_pxs = (2 * fractal_radius + 1) * (2 * fractal_radius + 1);
    int* fractal_intensities = (int*)malloc(sizeof(int) * fractal_pxs);
    double variance = 0.0;
    double average = 0.0;
    int intensity_level = 64;
    double max_variance = 0.0, min_variance = 1.0;
    UInt8 r, g, b;
    UInt8* pixel;
    
	// データプロバイダを取得する
	CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
    
    CFDataRef tmpData = CGDataProviderCopyData(dataProvider);
    CFMutableDataRef inputData = CFDataCreateMutableCopy(0, 0, tmpData);
    CFDataRef tmpData2 = CGDataProviderCopyData(dataProvider);
    CFMutableDataRef outputData = CFDataCreateMutableCopy(0, 0, tmpData2);
    UInt8 *buffer = (UInt8 *)CFDataGetMutableBytePtr(inputData);
    UInt8 *pOutBuffer = (UInt8 *)CFDataGetMutableBytePtr(outputData);
    
    
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
            memset(fractal_intensities, 0, sizeof(int) * fractal_pxs);
            memset(&sumR[0], 0, sizeof(sumR));
            memset(&sumG[0], 0, sizeof(sumG));
            memset(&sumB[0], 0, sizeof(sumB));
            
			// ピクセルのポインタを取得する
			UInt8* cpx = buffer + Y * bytesPerRow + X * 4;
            
			// RGBの値を取得する
            
            /* Split fractal. */
            for(y = -fractal_radius; y <= fractal_radius; y++) {
                if (Y + y < 0 || Y + y >= height) {
                    continue;
                }
                for(x = -fractal_radius; x <= fractal_radius; x++) {
                    if (X + x >= width || X + x < 0) {
                        continue;
                    }
                    N++;
                    index = ((Y + y) * width * 4) + ((X + x) * 4);
                    pixel = buffer + index;
                    r = *(pixel + 0);
                    g = *(pixel + 1);
                    b = *(pixel + 2);
                    current_intensity = (r + g + b)/3;
                    
                    index = ((y + fractal_radius) * (2 * fractal_radius + 1)) + (x + fractal_radius);
                    fractal_intensities[index] = current_intensity;
                    
                    average += current_intensity / 255.0;
                }
            }
            
            average /= (double)N;
            
            //NSLog(@"average: %f", average);
            
            for (int i = 0; i < fractal_pxs; i++) {
                variance += (fractal_intensities[i] / 255.0 - average) * (fractal_intensities[i] / 255.0 - average);
            }
            
            variance /= (double)N;
            //NSLog(@"variance: %lf", variance);
            if (variance > 0.1) {
                radius = RADIUS / 3;
            } else if (variance > 0.05) {
                radius = RADIUS / 2;
            }
            if (max_variance < variance) {
                max_variance = variance;
            }else if(min_variance > variance){
                min_variance = variance;
            }
            
            /* Calculate the highest intensity Neighbouring Pixels. */
            for(y = -radius; y <= radius; y++) {
                for(x = -radius; x <= radius; x++) {
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
    
	// 効果を与えたデータを作成する
	CFDataRef effectedData;
	effectedData = CFDataCreate(NULL, pOutBuffer, CFDataGetLength(tmpData));
    
	// 効果を与えたデータプロバイダを作成する
	CGDataProviderRef effectedDataProvider;
	effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    
	// 画像を作成する
	CGImageRef effectedCgImage = CGImageCreate(
                                               width, height,
                                               bitsPerComponent, bitsPerPixel, bytesPerRow,
                                               colorSpace, bitmapInfo, effectedDataProvider,
                                               NULL, shouldInterpolate, intent);
    
    UIImage* effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
	// 作成したデータを解放する
	CGImageRelease(effectedCgImage);
	CFRelease(effectedDataProvider);
	CFRelease(effectedData);
	CFRelease(tmpData);
	CFRelease(tmpData2);
    CFRelease(inputData);
    CFRelease(outputData);
    free(fractal_intensities);
    
    UIImageView* imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, 320.0f, height * 320.0f / width)];
    imgView.image = effectedImage;
    [self.view addSubview:imgView];
}

#pragma mark  delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage* imageOriginal = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if(imageOriginal){
        if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
            UIImageWriteToSavedPhotosAlbum(imageOriginal, nil, nil, nil);
        }
        [self processWithImage:imageOriginal];
    } else {
        __weak UnkoViewController* _self = self;
        NSURL* imageurl = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:imageurl
                 resultBlock: ^(ALAsset *asset)
         {
             ALAssetRepresentation *representation;
             representation = [asset defaultRepresentation];
             UIImage* imageOriginal = [[UIImage alloc] initWithCGImage:representation.fullResolutionImage];
             [_self processWithImage:imageOriginal];
         }
                failureBlock:^(NSError *error)
         {
         }
         ];
    }
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
