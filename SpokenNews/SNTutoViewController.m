//
//  SNTutoViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 17/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SNTutoViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SNTutoViewController ()

@end

@implementation SNTutoViewController

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
    [self applyMotionEffect:startBtn];
    [self applyMotionEffect:tutoBtn];
    [self applyMotionEffect:titleImgView];
    
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:5.0];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:-5.0];
    
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:-5.0];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:5.0];
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[yAxis,xAxis];
    
    [bgImgView addMotionEffect:group];
    bgImgView.transform = CGAffineTransformMakeScale(1.02, 1.02);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showTutoMovie{
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc]initWithContentURL:[[NSBundle mainBundle]URLForResource:@"tuto_hd" withExtension:@"mp4"]];
    [self presentMoviePlayerViewControllerAnimated:player];
}

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
