//
//  SpeakManager.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 8/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SpeakManager.h"

static SpeakManager* manager;
@implementation SpeakManager
#pragma mark - static method

+(SpeakManager*)sharedInstance{
    if(manager == nil)
    {
        manager = [[SpeakManager alloc]init];
    }
    return manager;
}

-(id)init{
    self = [super init];
    if(self)
    {
        NSLog(@"Speak Manager: super init");
        //get instance of appPlayer / musicPlayer to control the audio playback
        musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        //get the audio session
        session = [AVAudioSession sharedInstance];
        //configure the AVAudio session to Playback + OverrideMixWithOther
        [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
        //set the session as active
        [session setActive:YES error:nil];
        
        //iOS6
        /*
         UInt32 doChangeDefaultRoute = 1;
         AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
         */
        
        //register some notification for handling ipod music player playback
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        //register some notification for handling ipod music player playback
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePlayerState:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
        //[musicPlayer beginGeneratingPlaybackNotifications];
        
        //init the speak engine
        mNativeEngine = [[NativeTTS alloc]init];
        [mNativeEngine setDelegate:self];
        
        //    leave speace for eSpeak engine
        //    engine = [[ESpeakEngine alloc] init];
        //    [engine setLanguage:@"zhy"];
        //    [engine setSpeechRate:180];
        //    [engine setVolume:1.0];
    }
    return self;
}

-(void)forceStopSpeaking{
    [mNativeEngine stop];
}

-(BOOL)isAvaiableForSpeaking{
    return !isSpeaking;
}

-(void)enableDriving:(BOOL)_isDriving{
    if(_isDriving)
    {
        [self speak:@"開始駕駛，我將會為你提供新聞及交通資訊"];
    } else {
        //do nothing now sin
    }
}

-(void)forceSpeak:(id)obj{
    MPMusicPlaybackState state = musicPlayer.playbackState;
    if(isDebug)
    {
        NSLog(@"pause before speak and cache %ld", (long)state);
        NSLog(@"playing: %d, paused: %d interruped: %d", MPMusicPlaybackStatePlaying, MPMusicPlaybackStatePaused, MPMusicPlaybackStateInterrupted);
    }
    if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        if(isDebug)
            NSLog(@"pause and speak");
        [musicPlayer pause];
        isMusicPausedBySelf = YES;
        //speak route to callback;

    } else if(musicPlayer.playbackState == MPMusicPlaybackStateInterrupted)
    {
        if(![mNativeEngine isPlaying])
        {
            //[engine speakAndCache:checkstr((NSString*)obj)];
            //[mNativeEngine speak:checkstr((NSString*)obj)];
        }
        isMusicPausedBySelf = YES;
    }
    else if(musicPlayer.playbackState == MPMusicPlaybackStateStopped || musicPlayer.playbackState == MPMusicPlaybackStatePaused)
    {
        if(isDebug)
            NSLog(@"speak directly: %@", obj);
        isMusicPausedBySelf = NO;
        
        if(![mNativeEngine isPlaying]){
            //[engine speakAndCache:checkstr((NSString*)obj)];
            //[mNativeEngine speak:checkstr((NSString*)obj)];
        }
    }
    //self.nextSentenceToSpeak = (NSString*)obj;
    [mNativeEngine stop];
    [mNativeEngine speak:checkstr((NSString*)obj)];
}

-(void)speak:(id)obj{
    MPMusicPlaybackState state = musicPlayer.playbackState;
    if(isDebug)
    {
        NSLog(@"pause before speak and cache %ld", (long)state);
        NSLog(@"playing: %d, paused: %d interruped: %d", MPMusicPlaybackStatePlaying, MPMusicPlaybackStatePaused, MPMusicPlaybackStateInterrupted);
    }
    if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        if(isDebug)
            NSLog(@"pause and speak");
        [musicPlayer pause];
        isMusicPausedBySelf = YES;
        //speak route to callback;
        [mNativeEngine speak:checkstr((NSString*)obj)];
    } else if(musicPlayer.playbackState == MPMusicPlaybackStateInterrupted)
    {
        if(![mNativeEngine isPlaying])
        {
            //[engine speakAndCache:checkstr((NSString*)obj)];
            [mNativeEngine speak:checkstr((NSString*)obj)];
        }
        isMusicPausedBySelf = YES;
    }
    else if(musicPlayer.playbackState == MPMusicPlaybackStateStopped || musicPlayer.playbackState == MPMusicPlaybackStatePaused)
    {
        if(isDebug)
            NSLog(@"speak directly: %@", obj);
        isMusicPausedBySelf = NO;
        
        if(![mNativeEngine isPlaying]){
            //[engine speakAndCache:checkstr((NSString*)obj)];
            [mNativeEngine speak:checkstr((NSString*)obj)];
        }
    }
    self.nextSentenceToSpeak = (NSString*)obj;
}

#pragma mark - Meida Player Event
-(void)itemDidFinishPlaying
{
    //NSLog(@"Speak engine finished %d %d", MPMusicPlaybackStatePaused);
    MPMusicPlaybackState playbackState = musicPlayer.playbackState;
    if ( (playbackState == MPMusicPlaybackStatePaused  ||
          playbackState == MPMusicPlaybackStateInterrupted)&& isMusicPausedBySelf) {
        [musicPlayer play];
    }
}

-(void)didChangePlayerState:(NSNotification*)notification{
    
    /*
    MPMusicPlaybackState state = musicPlayer.playbackState;
    if(isDebug)
        NSLog(@"change player state to %ld", (long)state);
    if((musicPlayer.playbackState == MPMusicPlaybackStatePaused) && isMusicPausedBySelf)
    {
        if(isDebug)
            NSLog(@"mp paused");
        if(self.nextSentenceToSpeak!= nil)
        {
            if(isDebug)
                NSLog(@"speak and cache: %@", self.nextSentenceToSpeak);
            if(isSpeaking)
            {
                //[engine speakAndCache:checkstr((NSString*)speakObj)];
                [mNativeEngine speak:checkstr((NSString*)(self.nextSentenceToSpeak))];
            }
        }
    }
     */
}

#pragma mark - Native TTS delegate

-(void)didFinishSpeaking{
    //replay the music if needed
    if(isMusicPausedBySelf)
    {
        [musicPlayer play];
    }
}



#pragma mark - helper function check str
NSString* checkstr(NSString* str)
{
    str = [str stringByReplacingOccurrencesOfString:@"擠塞" withString:@"擠失"];
    str = [str stringByReplacingOccurrencesOfString:@"銅鑼灣" withString:@"同羅彎"];
    str = [str stringByReplacingOccurrencesOfString:@"大嶼山" withString:@"大愚山"];
    str = [str stringByReplacingOccurrencesOfString:@"間" withString:@"諫"];
    str = [str stringByReplacingOccurrencesOfString:@"之間" withString:@"之奸"];
    str = [str stringByReplacingOccurrencesOfString:@"回復" withString:@"回伏"];
    return str;
}
@end
