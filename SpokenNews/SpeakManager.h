//
//  SpeakManager.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 8/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "NativeTTS.h"

@interface SpeakManager : NSObject <NativeTTSDelegate>
{
    BOOL isSpeaking;
    
    //handle media player state
    BOOL isMusicPausedBySelf;
    
    MPMusicPlayerController* musicPlayer;
    
    //audio session
    AVAudioSession* session;
    
    //Native TTS Engine
    NativeTTS  *mNativeEngine;
    
    //leave speak for eSpeakEngine
}
-(BOOL)isAvaiableForSpeaking;
-(void)forceStopSpeaking;
@property (nonatomic, copy) NSString* nextSentenceToSpeak;
//instance method
-(id)init;
-(void)speak:(id)obj;
-(void)forceSpeak:(id)obj;
//static method
+(SpeakManager*)sharedInstance;

-(void)enableDriving:(BOOL)_isDriving;
@end
