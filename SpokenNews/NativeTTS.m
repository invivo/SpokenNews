//
//  NativeTTS.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 1/7/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import "NativeTTS.h"

@implementation NativeTTS

@synthesize delegate;

-(id)init
{
    self = [super init];
    if(self)
    {
        //some init
        _synth = [[AVSpeechSynthesizer alloc]init];
        _voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-HK"];
        
        [_synth setDelegate:self];
    }
    return self;
}


-(void)speak:(NSString*)msg
{
    _utterance = [[AVSpeechUtterance alloc]initWithString:msg];
    [_utterance setRate:0.25f];
    NSLog(@"try speaking");
    [_utterance setVoice:_voice];
    [_synth speakUtterance:_utterance];
}

-(void)stop{
    if([_synth isSpeaking])
    {
        NSLog(@"force stop speaking");
        if(![_synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate])
        {
            [_synth stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        }
    }
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance
{
    _isPlaying = YES;
    NSLog(@"start speaking");
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didPauseSpeechUtterance:(AVSpeechUtterance *)utterance{
        _isPlaying = NO;
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didCancelSpeechUtterance:(AVSpeechUtterance *)utterance
{
    _isPlaying = NO;
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didContinueSpeechUtterance:(AVSpeechUtterance *)utterance{
    _isPlaying = YES;    
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    NSLog(@"complete speaking");
    _isPlaying = NO;
    if(delegate != nil)
    {
        if([delegate respondsToSelector:@selector(didFinishSpeaking)])
        {
            [delegate didFinishSpeaking];
        }
    }
}

-(BOOL)isPlaying
{
//    return _isPlaying;
    return [_synth isSpeaking];
}

@end
