//
//  SNCamViewController.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
@interface SNCamViewController : UIViewController
{
    IBOutlet UIImageView *camView;
    IBOutlet UIImageView *camBlurTopView;
    
    CIContext *_ciContext;
    EAGLContext *_eaglContext;
}
@end
