//
//  SNSpeedCamViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 14/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SNSpeedCamViewController.h"
#import "ContentManager.h"
@interface SNSpeedCamViewController ()

@end

@implementation SNSpeedCamViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    imgView.image = self.blurImg;
    
    speedCamLabel.alpha = 0;
    speedLabel.alpha = 0;
    speedMsgLabel.alpha = 0;
    closeBtn.transform = CGAffineTransformMakeTranslation(0, 200);
    alertIcon.alpha =0;
    alertBadge.transform = CGAffineTransformMakeTranslation(0, -50);
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

NSTimer * t;
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^(void){
        speedCamLabel.alpha = 1;
        speedLabel.alpha = 1;
        speedMsgLabel.alpha = 1;
        closeBtn.transform = CGAffineTransformMakeTranslation(0, 0);
        alertIcon.alpha =1;
        alertBadge.transform = CGAffineTransformMakeTranslation(0, 0);
    }completion:nil];
    t =[NSTimer scheduledTimerWithTimeInterval:6.0f target:self selector:@selector(closeBtnClicked:) userInfo:nil repeats:NO];
    
    BOOL isDemo = NO;
    if(isDemo)
    {
        [[ContentManager sharedInstance]enqueueToSpeak:@"請留意車速" withPriority:1];
    }
}

- (IBAction)closeBtnClicked:(id)sender{
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^(void){
        speedCamLabel.alpha = 0;
        speedLabel.alpha = 0;
        speedMsgLabel.alpha = 0;
        closeBtn.transform = CGAffineTransformMakeTranslation(0, 200);
        alertIcon.alpha =0;
        alertBadge.transform = CGAffineTransformMakeTranslation(0, -50);
        if(t!= nil)
        {
            if([t isValid])
            {
                [t invalidate];
            }
        }
    }completion:^(BOOL isFinished){
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
