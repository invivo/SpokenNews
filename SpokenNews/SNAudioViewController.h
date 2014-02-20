//
//  SNAudioViewController.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@interface SNAudioViewController : UIViewController < MPMediaPickerControllerDelegate>
{
    IBOutlet UILabel *trackLabel;
    IBOutlet UIButton *playbackBtn;
}
@end
