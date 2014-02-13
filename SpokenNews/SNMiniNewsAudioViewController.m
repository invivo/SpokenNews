//
//  SNMiniNewsAudioViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SNMiniNewsAudioViewController.h"
#import "ContentManager.h"
@interface SNMiniNewsAudioViewController ()

@end

@implementation SNMiniNewsAudioViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if([[ContentManager sharedInstance]lastNewsString] != nil)
    {
        [lastestNewsLabel setText:[[ContentManager sharedInstance]lastNewsString]];
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(newsUpdate:) name:@"NewsUpdate" object:nil];
//                [[NSNotificationCenter defaultCenter]postNotificationName:@"NewsUpdate" object:self.lastNewsString userInfo:nil];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"NewsUpdate" object:nil];
}

-(void)newsUpdate:(NSNotification*)notification{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [lastestNewsLabel setText:[notification object]];
    });
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
