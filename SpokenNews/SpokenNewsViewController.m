//
//  SpokenNewsViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SpokenNewsViewController.h"
#import "SNSpeedCamViewController.h"
#import "SNSearchViewController.h"
#import "AppDelegate.h"

@interface SpokenNewsViewController ()

@end

@implementation SpokenNewsViewController
@synthesize ciContext = _ciContext;

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
    [self limitScrollViewContentSize];
    
    spokenNewsVC = self;
    
    bubbleImg = [UIImage imageNamed:@"news_bubble_ui"];
    scretchedBubbleImage = [bubbleImg resizableImageWithCapInsets:UIEdgeInsetsMake(30, 0, 31, 0)];
    
    newsBubbleBGView.image = scretchedBubbleImage;
    
    // setup the GLKView for video/image preview
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _ciContext =
    [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace : [NSNull null]} ];
    
    bubbleSize = CGRectMake(0,111,320,69);
    //    bubbleLargeSize = CGRectMake(0,8,320,172);
    bubbleLargeSize = CGRectMake(0,8+5,320,162);
    
    [self applyMotionEffect:theScorllView];
    [self applyMotionEffect:controlUI];
    [self applyMotionEffect:camLocLabel];
    
    
    
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:5.0];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:-5.0];
    
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-5.0];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:5.0];
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[yAxis,xAxis];
    
    [bgCamView addMotionEffect:group];
    bgCamView.transform = CGAffineTransformMakeScale(1.02, 1.02);
    
    
}



-(void)setTrafficCamLoc:(NSString*)location withTime:(NSString*)time{
    [trafficCamLocLabel setText:location];
    [trafficCamTimeLabel setText:time];
}


BOOL isLaunched = NO;
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    BOOL isDemo = NO;
    if([[PrefStore sharedInstance]isFirstLaunch] && !isDemo)// && !isLaunched && !isDemo)
    {
        [self performSegueWithIdentifier:@"showFirstLaunch" sender:nil];
        [[PrefStore sharedInstance]setIsFirstLaunch:NO];
        isLaunched = YES;
    }
    
    if(!isDriving)
    {
        [self stopFeedingNews];
    }
    
    //    UIImage *img = [camView image];
    //    CIImage *originalImage = [CIImage imageWithCGImage:img.CGImage];
    //    originalImage = [originalImage imageByCroppingToRect:CGRectMake(0, img.size.height-10, img.size.width, 10)];
    ////    CIFilter *f = [CIFilter filterWithName:@"CIGaussianBlur"];
    ////    [f setValue:originalImage forKey:kCIInputImageKey];
    ////    [f setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
    //    CIImage *outputImage = originalImage; //f.outputImage;
    //    [camBlurTopView setImage:
    //        [UIImage imageWithCGImage:[_ciContext createCGImage:outputImage fromRect:outputImage.extent]]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showSpeedCamAlert) name:@"SpeedCamDetected" object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SpeedCamDetected" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button click
- (void)showSpeedCamAlert{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self speedCamBtnClicked:nil];
    });
}


- (IBAction)driveBtnClicked:(id)sender{
    if(isDriving){
        [self stopFeedingNews];
    } else {
        if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined)
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"第一次啟動自動更新功能"
                                                               message:@"因為 SpokenNews 需要運用定位服務才能正常運作。請在按明白後顯示的對話框按\"OK\" 或 \"好\" 以啟動定位功能。"
                                                              delegate:self
                                                     cancelButtonTitle:@"明白"
                                                     otherButtonTitles: nil];
            [alertView show];
        } else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)
        {
            [self startFeedingNews];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"尚未啟動定位功能"
                                                               message:@"如要啟動自動更新功能，請將 設定 > 穩私 > 定位服務 > 定位服務 及 Spoken News 旁的開關設定為「開」。"
                                                              delegate:nil
                                                     cancelButtonTitle:@"明白"
                                                     otherButtonTitles: nil];
            [alertView show];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self startFeedingNews];
}

-(void)startFeedingNews{
    [driveBtn setImage:[UIImage imageNamed:@"drive_btn_on"] forState:UIControlStateNormal];
    ContentManager *contentManager = [ContentManager sharedInstance];
    [contentManager startFeedingContent];
    [UIView animateWithDuration:0.5f animations:^(void){
        [trafficCamPosView setAlpha:1];
    }];
    
    if([newsListController.fetchedResultsController fetchedObjects].count > 0)
    {
        [self releaseScrollViewContentSizeWithAnimation:NO];
    }
    isDriving = YES;
}

-(void)stopFeedingNews{
    [driveBtn setImage:[UIImage imageNamed:@"drive_btn_off"] forState:UIControlStateNormal];
    ContentManager *contentManager = [ContentManager sharedInstance];
    [contentManager stopFeedingContent];
    [UIView animateWithDuration:0.5f animations:^(void){
        [trafficCamPosView setAlpha:0];
    }];
    isDriving = NO;
}

UIImage *blurImg;
- (IBAction)speedCamBtnClicked:(id)sender{
    UIImage *img = [self screenshot];
    CIImage *originalImage = [CIImage imageWithCGImage:img.CGImage];
    CIFilter *f = [CIFilter filterWithName:@"CIGaussianBlur"];
    [f setValue:originalImage forKey:kCIInputImageKey];
    [f setValue:[NSNumber numberWithFloat:5] forKey:@"inputRadius"];
    CIImage *outputImage = f.outputImage;
    blurImg = [UIImage imageWithCGImage:[_ciContext createCGImage:outputImage fromRect:outputImage.extent]];
    
    [self performSegueWithIdentifier:@"speedCamSegue" sender:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"speedCamSegue"])
    {
        SNSpeedCamViewController* vc = (SNSpeedCamViewController*)[segue destinationViewController];
        [vc setBlurImg:blurImg];
    } else if([[segue identifier]isEqualToString:@"showGasSegue"]){
        SNSearchViewController* vc = (SNSearchViewController*)[segue destinationViewController];
        [vc setSearchType:1];
    } else if([[segue identifier]isEqualToString:@"showParkingSegue"]){
        SNSearchViewController* vc = (SNSearchViewController*)[segue destinationViewController];
        [vc setSearchType:0];
    } else if([[segue identifier]isEqualToString:@"showBigNewsSegue"]){
        newsListController = (SNNewsListController*)[segue destinationViewController];
    }
}

#pragma mark - bubble resize
BOOL isLarge;
-(IBAction)enlargetOrShrinkBubble:(id)sender{
    if(!isLarge){
        [self enlargeBubble:sender];
    } else {
        [self shrinkBubble:sender];
    }
    isLarge = !isLarge;
    
    /*
     if(blurStep <= 0)
     {
     [self showBlurScreen];
     } else {
     [self showSharpScreen];
     }
     */
}

-(IBAction)enlargeBubble:(id)sender{
    //    [UIView animateWithDuration:0.5f animations:^(void){
    //        newsView.frame = bubbleLargeSize;
    //        audioControl.transform = CGAffineTransformMakeTranslation(0, -250);
    //    }];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^(void){
        newsView.frame = bubbleLargeSize;
        audioControl.transform = CGAffineTransformMakeTranslation(0, -250);
    }completion:nil];
}

-(IBAction)shrinkBubble:(id)sender{
    //    [UIView animateWithDuration:0.5f animations:^(void){
    //        newsView.frame = bubbleSize;
    //        audioControl.transform = CGAffineTransformMakeTranslation(0, 0);
    //    }];
    
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationCurveEaseInOut animations:^(void){
        newsView.frame = bubbleSize;
        audioControl.transform = CGAffineTransformMakeTranslation(0, 0);
    }completion:nil];
}

#pragma mark - blue view
double blurRadius;
int blurDest;
int blurStep;
UIImage *bgImg;
NSTimer *timer;
- (void)showBlurScreen{
    UIImage *img = [self screenshot];
    bgImg = img;
    blurRadius = 0;
    blurDest = 15;
    blurStep = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:1/24 target:self selector:@selector(toBlur) userInfo:nil repeats:YES];
}

-(void)toBlur{
    @autoreleasepool {
        blurStep ++;
        CIImage *originalImage = [CIImage imageWithCGImage:bgImg.CGImage];
        CIFilter *f = [CIFilter filterWithName:@"CIGaussianBlur"];
        [f setValue:originalImage forKey:kCIInputImageKey];
        [f setValue:[NSNumber numberWithFloat:blurRadius] forKey:@"inputRadius"];
        CIImage *outputImage = f.outputImage;
        [blurBGView setImage:
         [UIImage imageWithCGImage:[_ciContext createCGImage:outputImage fromRect:outputImage.extent]]];
        [self.view bringSubviewToFront:blurBGView];
        
        double stepPercentage = (blurStep/24.0);
        blurRadius = ((blurStep/24.0)*blurDest);
        CGRect newFrame = CGRectMake(0 + (-blurDest*2)*stepPercentage, 0 + (-blurDest*2)*stepPercentage,
                                     320 + (blurDest*4)*stepPercentage, 568 + (blurDest*4)*stepPercentage);
        [blurBGView setFrame:newFrame];
        
        if(blurStep >= 24)
        {
            if(timer != nil)
            {
                [timer invalidate];
            }
        }
    }
}

- (void)showSharpScreen{
    timer = [NSTimer scheduledTimerWithTimeInterval:1/24 target:self selector:@selector(toSharp) userInfo:nil repeats:YES];
}

-(void)toSharp{
    @autoreleasepool {
        blurStep --;
        CIImage *originalImage = [CIImage imageWithCGImage:bgImg.CGImage];
        CIFilter *f = [CIFilter filterWithName:@"CIGaussianBlur"];
        [f setValue:originalImage forKey:kCIInputImageKey];
        [f setValue:[NSNumber numberWithFloat:blurRadius] forKey:@"inputRadius"];
        CIImage *outputImage = f.outputImage;
        [blurBGView setImage:
         [UIImage imageWithCGImage:[_ciContext createCGImage:outputImage fromRect:outputImage.extent]]];
        [self.view bringSubviewToFront:blurBGView];
        
        double stepPercentage = (blurStep/24.0);
        blurRadius = ((blurStep/24.0)*blurDest);
        CGRect newFrame = CGRectMake(0 + (-blurDest*2)*stepPercentage, 0 + (-blurDest*2)*stepPercentage,
                                     320 + (blurDest*4)*stepPercentage, 568 + (blurDest*4)*stepPercentage);
        [blurBGView setFrame:newFrame];
        
        if(blurStep <= 0)
        {
            if(timer != nil)
            {
                [timer invalidate];
            }
        }
    }
}

- (UIImage *) screenshot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1); //[UIScreen mainScreen].scale);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - exit segue

-(IBAction)exit:(UIStoryboardSegue*)segue{
    
}

#pragma mark - parallax

- (void)applyMotionEffect:(UIView*)view
{
    //    view.layer.transform
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-10.0];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:10.0];
    
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:10.0];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:-10.0];
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[yAxis,xAxis];
    
    [view addMotionEffect:group];
}


-(void)limitScrollViewContentSize{
    [newsScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    newsScrollView.contentSize = CGSizeMake(320, newsScrollView.frame.size.height);
}
-(void)releaseScrollViewContentSizeWithAnimation:(BOOL)isAnimated{
    if(newsScrollView.contentSize.width > 320)
    {
        
    } else {
        newsScrollView.contentSize = CGSizeMake(640, newsScrollView.frame.size.height);
        if(isAnimated)
        {
            [newsScrollView setContentOffset:CGPointMake(320, 0) animated:YES];
            [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(gobackToAudio) userInfo:nil repeats:NO];
        }
    }
}

-(void)gobackToAudio{
    [newsScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
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
