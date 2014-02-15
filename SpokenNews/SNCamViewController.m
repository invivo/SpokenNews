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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // setup the GLKView for video/image preview
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    _ciContext =
    [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
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
    //    CIFilter *f = [CIFilter filterWithName:@"CIGaussianBlur"];
    //    [f setValue:originalImage forKey:kCIInputImageKey];
    //    [f setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    CIImage *outputImage = originalImage; //f.outputImage;
    [camBlurTopView setImage:
     [UIImage imageWithCGImage:[_ciContext createCGImage:outputImage fromRect:outputImage.extent]]];

        
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedLocationUpdateNotification:) name:@"LocationUpdate" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedLocationUpdateNotification:) name:@"LocationUpdate" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"LocationUpdate" object:nil];
}

-(void)receivedLocationUpdateNotification:(NSNotification*)notification{
    //NSLog(@"%@", notification);
    [UIView animateWithDuration:0.2f animations:^(void){
        updateNotice.alpha = 1.0f;
    } completion:^(BOOL finished){
        CLLocation *loc = [notification object];
        CamMapItem *nearestCam = [[PSIDataStore sharedInstance]getNearestTrafficCam:loc];
        NSString *addr = [nearestCam webAddress];
        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:addr]];
        [request setCompletionBlock:^(void){
            NSData *imgData = [request responseData];
            UIImage *img = [UIImage imageWithData:imgData];
            CIImage *originalImage = [CIImage imageWithCGImage:img.CGImage];
            
            originalImage = [originalImage imageByCroppingToRect:CGRectMake(0, img.size.height-10, img.size.width, 10)];
            
            [camView setImage:img];
            CIImage *outputImage = originalImage; //f.outputImage;
            [camBlurTopView setImage:
             [UIImage imageWithCGImage:[_ciContext createCGImage:outputImage fromRect:outputImage.extent]]];
            
            if(spokenNewsVC!=nil)
            {
                NSLocale *hkLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh-Hant-HK"];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"hh:mmaaa"];
                NSLog(@"%@", [formatter stringFromDate:[NSDate date]]);
                
                [spokenNewsVC setTrafficCamLoc:[nearestCam title]
                                      withTime:[[formatter stringFromDate:[NSDate date]]uppercaseString]];
                
                [self hideDefaultBG];
                
                [UIView animateWithDuration:0.2f animations:^(void){
                    updateNotice.alpha = 0.0f;
                }];
            }
            
            request = nil;
        }];
        [request setFailedBlock:^(void){
            request = nil;
            [UIView animateWithDuration:0.2f animations:^(void){
                updateNotice.alpha = 0.0f;
            }];
        }];
        [request startAsynchronous];
    }];
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
