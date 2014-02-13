//
//  SNAudioViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SNAudioViewController.h"

@interface SNAudioViewController ()

@end

@implementation SNAudioViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([[MPMusicPlayerController iPodMusicPlayer]playbackState] == MPMusicPlaybackStatePaused ||
       [[MPMusicPlayerController iPodMusicPlayer]playbackState] == MPMusicPlaybackStatePlaying)
    {
        MPMediaItem *item = [[MPMusicPlayerController iPodMusicPlayer]nowPlayingItem];
        [trackLabel setText:[item valueForProperty:MPMediaItemPropertyTitle]];
    } else {
        [trackLabel setText:@""];
    }
    [self setPlayBtnImage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePlayerState:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangePlayingItem:) name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
    
    NSDictionary *dict = [[MPNowPlayingInfoCenter defaultCenter]nowPlayingInfo];
    NSLog(@"now playing info: %@", dict);
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:nil];
}

#pragma mark - notification call back

-(void)didChangePlayerState:(NSNotification*)notification{
    [self setPlayBtnImage];
}

-(void)didChangePlayingItem:(NSNotification*)notificaiton{
    MPMediaItem *item = [[MPMusicPlayerController iPodMusicPlayer]nowPlayingItem];
    [trackLabel setText:[item valueForProperty:MPMediaItemPropertyTitle]];
}

#pragma mark - UI action
- (IBAction)playBtnClicked:(id)sender
{
    if([[MPMusicPlayerController iPodMusicPlayer]playbackState] == MPMusicPlaybackStatePaused)
    {
        [[MPMusicPlayerController iPodMusicPlayer]play];
    } else if([[MPMusicPlayerController iPodMusicPlayer]playbackState] == MPMusicPlaybackStatePlaying){
        [[MPMusicPlayerController iPodMusicPlayer]pause];
    }
}

- (IBAction)nextBtnClicked:(id)sender
{
    [[MPMusicPlayerController iPodMusicPlayer]skipToPreviousItem];
}

-(IBAction)backBtnClicked:(id)sender{
    [[MPMusicPlayerController iPodMusicPlayer]skipToNextItem];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - update ui

-(void)setPlayBtnImage{
    if([[MPMusicPlayerController iPodMusicPlayer]playbackState] == MPMusicPlaybackStatePlaying)
    {
        [playbackBtn setImage:[UIImage imageNamed:@"audio_btn_pause"] forState:UIControlStateNormal];
    } else {
        [playbackBtn setImage:[UIImage imageNamed:@"audio_btn_play"] forState:UIControlStateNormal];
    }
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
