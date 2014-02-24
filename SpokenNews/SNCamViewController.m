//
//  SNCamViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SNCamViewController.h"
#import "PSIDataStore.h"
#import "CamMapItem.h"
#import "GlobalHeader.h"

@interface SNCamViewController ()

@end

@implementation SNCamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

UIImage *_maskingImage;
UIImage *_transImage;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // setup the GLKView for video/image preview
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    _ciContext =
    [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    queue = [[NSOperationQueue alloc]init];
    [queue setMaxConcurrentOperationCount:1];
    
    _maskingImage = [UIImage imageNamed:@"imgMask"];
    _transImage = [UIImage imageNamed:@"trans"];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UIImage *img = [camView image];
    CIImage *originalImage = [CIImage imageWithCGImage:img.CGImage];
    
#if TARGET_IPHONE_SIMULATOR
    originalImage = [originalImage imageByCroppingToRect:CGRectMake(0, img.size.height-10, img.size.width, 10)];
#else
    originalImage = [originalImage imageByCroppingToRect:CGRectMake(0, img.size.height-10, img.size.width, 10)];
#endif
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedLocationUpdateNotification:) name:@"LocationUpdate" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedLocationUpdateNotification:) name:@"LocationUpdate" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"LocationUpdate" object:nil];
}

-(void)receivedLocationUpdateNotification:(NSNotification*)notification{
    
    // @autoreleasepool {
    //NSLog(@"%@", notification);
    
    //won't load the same cam
    CLLocation *loc = [notification object];
    CamMapItem *nearestCam = [[PSIDataStore sharedInstance]getNearestTrafficCam:loc];
    if(![[nearestCam serial] isEqualToString:lastCamSerial])
    {
        if([queue operationCount] > 1)
        {
            NSLog(@"cancel queued operation");
            [queue cancelAllOperations];
        }
        
        if(defaultBG.alpha > 1.0f)
        {
            
        } else {
            UIImage *img = [self screenshot];
            CIImage *originalImage = [CIImage imageWithCGImage:img.CGImage];
            CIFilter *f = [CIFilter filterWithName:@"CIGaussianBlur"];
            [f setValue:originalImage forKey:kCIInputImageKey];
            [f setValue:[NSNumber numberWithFloat:5] forKey:@"inputRadius"];
            CIImage *outputImage = f.outputImage;
            UIImage* blurImg = [UIImage imageWithCGImage:[_ciContext createCGImage:outputImage fromRect:outputImage.extent]];
            [defaultBG setImage:blurImg];
        }
        
        lastCamSerial = [nearestCam serial];
        [UIView animateWithDuration:0.5f animations:^(void){
            //if(defaultBG.alpha > 0)
            {
                //updateNotice.alpha = 1.0f;
                defaultBG.alpha = 1.0f;
            }
        } completion:^(BOOL finished){
            NSString *addr = [nearestCam webAddress];
            __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:addr]];
            [request setCompletionBlock:^(void){
                NSData *imgData = [request responseData];
                
                UIImage *img = [UIImage imageWithData:imgData];
                CIImage *originalImage = [CIImage imageWithCGImage:img.CGImage];
                
                CIFilter *f3 = [CIFilter filterWithName:@"CIBlendWithMask"];
                [f3 setValue:originalImage forKey:kCIInputImageKey];
                [f3 setValue:[CIImage imageWithCGImage:_transImage.CGImage]
                      forKey:@"inputBackgroundImage"];
                [f3 setValue:[CIImage imageWithCGImage:_maskingImage.CGImage]
                      forKey:@"inputMaskImage"];
                CIImage *oi = f3.outputImage;
                [camView setImage:[UIImage imageWithCGImage:[_ciContext createCGImage:oi fromRect:oi.extent]]];
                
                originalImage = [originalImage imageByCroppingToRect:CGRectMake(0,
                                                                                img.size.height-40,
                                                                                img.size.width, 40)];
                
                CIFilter *f = [CIFilter filterWithName:@"CIGaussianBlur"];
                [f setValue:originalImage forKey:kCIInputImageKey];
                [f setValue:[NSNumber numberWithFloat:10.0f] forKey:@"inputRadius"];
                
                CIImage *secondPass = f.outputImage;
                for(int i =0; i<1; i++)
                {
                    CIFilter *f2 = [CIFilter filterWithName:@"CISourceAtopCompositing"];
                    [f2 setValue:secondPass forKey:kCIInputImageKey];
                    [f2 setValue:originalImage forKey:@"inputBackgroundImage"];
                    secondPass = f2.outputImage;
                }
                
                CIImage *outputImage = secondPass; //f.outputImage;
                //[originalImage imageByCroppingToRect:CGRectMake(0, img.size.height-10, img.size.width, 10)];
                
                [camBlurTopView setImage:
                 [UIImage imageWithCGImage:[_ciContext createCGImage:outputImage fromRect:originalImage.extent]]];
                
                if(spokenNewsVC!=nil)
                {
                    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                    [formatter setDateFormat:@"hh:mmaaa"];
                    NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
                    
                    [spokenNewsVC setTrafficCamLoc:[nearestCam title]
                                          withTime:[[formatter stringFromDate:[NSDate date]]uppercaseString]];
                    
                    [self hideDefaultBG];
                    
                    [UIView animateWithDuration:0.3f animations:^(void){
                        updateNotice.alpha = 0.0f;
                    }];
                }
                request = nil;
            }];
            [request setFailedBlock:^(void){
                [UIView animateWithDuration:0.3f animations:^(void){
                    updateNotice.alpha = 0.0f;
                }];
                request = nil;
            }];
            [queue addOperation:request];
        }];
    }
}

-(void)showDefaultBG{
    [UIView animateWithDuration:0.5f animations:^(void){
        [defaultBG setAlpha:1.0f];
    }];
}
-(void)hideDefaultBG{
    [UIView animateWithDuration:0.5f animations:^(void){
        [defaultBG setAlpha:0.0f];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIImage *) screenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1); //[UIScreen mainScreen].scale);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
