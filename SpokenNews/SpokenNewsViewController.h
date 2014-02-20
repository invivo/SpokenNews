//
//  SpokenNewsViewController.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "ContentManager.h"
#import "GlobalHeader.h"
#import "SNNewsListController.h"

@interface SpokenNewsViewController : UIViewController<UIAlertViewDelegate>
{
    IBOutlet UIView *newsView;
    IBOutlet UIView *audioControl;
    
    IBOutlet UIImageView *camView;
    IBOutlet UIImageView *camBlurTopView;
    
    IBOutlet UIImageView *newsBubbleBGView;
    
    IBOutlet UIImageView *blurBGView;
    
    IBOutlet UIView *controlUI;
    IBOutlet UIView *camLocLabel;
    IBOutlet UIView *theScorllView;
    IBOutlet UIView *bgCamView;
    
    IBOutlet UILabel *trafficCamTimeLabel;
    IBOutlet UILabel *trafficCamLocLabel;
    IBOutlet UIView *trafficCamPosView;
    
    IBOutlet UIScrollView *newsScrollView;
    
    CIContext *_ciContext;
    EAGLContext *_eaglContext;
    
    UIImage *bubbleImg;
    UIImage *scretchedBubbleImage;
    
    CGRect bubbleSize;
    CGRect bubbleLargeSize;
    
    IBOutlet UIButton* driveBtn;
    BOOL isDriving;
    
    SNNewsListController *newsListController;
}
@property (nonatomic, strong) CIContext *ciContext;
-(void)startFeedingNews;
-(void)stopFeedingNews;
-(void)limitScrollViewContentSize;
-(void)releaseScrollViewContentSizeWithAnimation:(BOOL)isAnimated;
-(void)setTrafficCamLoc:(NSString*)location withTime:(NSString*)time;
@end
