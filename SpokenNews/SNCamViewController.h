//
//  SNCamViewController.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import "ASIHTTPRequest.h"

@interface SNCamViewController : UIViewController
{
    IBOutlet UIImageView *camView;
    IBOutlet UIImageView *camBlurTopView;
    
    IBOutlet UIImageView *defaultBG;
 
    IBOutlet UIView *updateNotice;
    CIContext *_ciContext;
    EAGLContext *_eaglContext;
}
-(void)showDefaultBG;
-(void)hideDefaultBG;

@end
