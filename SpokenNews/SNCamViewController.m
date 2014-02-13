//
//  SNCamViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SNCamViewController.h"

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
