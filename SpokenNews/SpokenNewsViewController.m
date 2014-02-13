//
//  SpokenNewsViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SpokenNewsViewController.h"

@interface SpokenNewsViewController ()

@end

@implementation SpokenNewsViewController

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
}


- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
//    UIImage *img = [camView image];
//    CIImage *originalImage = [CIImage imageWithCGImage:img.CGImage];
//    originalImage = [originalImage imageByCroppingToRect:CGRectMake(0, img.size.height-10, img.size.width, 10)];
////    CIFilter *f = [CIFilter filterWithName:@"CIGaussianBlur"];
////    [f setValue:originalImage forKey:kCIInputImageKey];
////    [f setValue:[NSNumber numberWithFloat:5.0f] forKey:@"inputRadius"];
//    CIImage *outputImage = originalImage; //f.outputImage;
//    [camBlurTopView setImage:
//        [UIImage imageWithCGImage:[_ciContext createCGImage:outputImage fromRect:outputImage.extent]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - button click
- (IBAction)driveBtnClicked:(id)sender{
    if(isDriving){
        [driveBtn setImage:[UIImage imageNamed:@"drive_btn_off"] forState:UIControlStateNormal];
        ContentManager *contentManager = [ContentManager sharedInstance];
        [contentManager stopFeedingContent];
    } else {
        [driveBtn setImage:[UIImage imageNamed:@"drive_btn_on"] forState:UIControlStateNormal];
        ContentManager *contentManager = [ContentManager sharedInstance];
        [contentManager startFeedingContent];
    }
    isDriving = !isDriving;
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
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    
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
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-20.0];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:20.0];
    
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:10.0];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:-10.0];
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[yAxis,xAxis];
    
    [view addMotionEffect:group];
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
