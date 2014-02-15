//
//  SNSpeedCamViewController.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 14/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNSpeedCamViewController : UIViewController
{
    IBOutlet UILabel *speedLabel;
    IBOutlet UILabel *speedMsgLabel;
    IBOutlet UIButton *closeBtn;
    IBOutlet UIView *alertBadge;
    IBOutlet UIImageView *imgView;
    IBOutlet UIView *alertIcon;
    IBOutlet UILabel *speedCamLabel;
}
@property (nonatomic, strong) UIImage *blurImg;
@end