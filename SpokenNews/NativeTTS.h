//
//  NativeTTS.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 1/7/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol NativeTTSDelegate <NSObject>

-(void)didFinishSpeaking;

@end

@interface NativeTTS : NSObject <AVSpeechSynthesizerDelegate>
{
    BOOL _isPlaying;
}

//property
@property (nonatomic, strong) AVSpeechSynthesisVoice *voice;
@property (nonatomic, strong) AVSpeechSynthesizer *synth;
@property (nonatomic, strong) AVSpeechUtterance *utterance;

//function
-(void)speak:(NSString*)msg;
-(void)stop;

//statue accessor
-(BOOL)isPlaying;


@property (nonatomic, assign) id<NativeTTSDelegate> delegate;
@end
