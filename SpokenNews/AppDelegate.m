//
//  AppDelegate.m
//  SpokenNews
//
//  Created by Kwok Yu Ho on 11/1/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import "AppDelegate.h"
#import "TFHpple.h"
//#import <AVFoundation/AVFoundation.h>
#import "GlobalHeader.h"
#import "NewsData.h"
#import "NewsViewController.h"
#import <AudioToolbox/AudioToolbox.h>
//#import "KMLParser.h"
#import "PSIDataStore.h"


@implementation AppDelegate

#pragma mark - application delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    isDebug = YES;
    isTerminated = NO;
    
    [PSIDataStore sharedInstance];
    [self doInitDB];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    if([InvivoDeviceUtility deviceSupportAutoLayout])
    {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        self.window.rootViewController = [sb instantiateInitialViewController];
    }
    else {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        self.window.rootViewController = [sb instantiateInitialViewController];
    }
    
    prefStore = [PrefStore sharedInstance];
    contentManager = [ContentManager sharedInstance];
    //    [contentManager startFeedingContent];
    
    //disable idle timer
    [[UIApplication sharedApplication]setIdleTimerDisabled:YES];
    
    if([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey])
    {
        isBackground = YES;
    } else {
        isBackground = NO;
    }
    
    [self.window makeKeyAndVisible];
    
    
    NSLog(@"did finish launch");
    
    
    return YES;
}

-(void)doInitDB{
    coreDataHelper = [[CoreDataHelper alloc]init];
    
    if(YES)
    {
        NSManagedObjectContext * context = [coreDataHelper managedObjectContext];
        NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"NewsData" inManagedObjectContext:context]];
        NSArray * result = [context executeFetchRequest:fetch error:nil];
        for (id news in result)
            [context deleteObject:news];
    }
}

-(void)doInitWork{
    //create the speak queue
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    isBackground = YES;
    UIApplication *app = [UIApplication sharedApplication];
    backgroundTask = [app beginBackgroundTaskWithExpirationHandler:^{
        if(backgroundTask != UIBackgroundTaskInvalid)
        {
            backgroundTask = UIBackgroundTaskInvalid;
        }
    }];
    
    [[MPMusicPlayerController iPodMusicPlayer] endGeneratingPlaybackNotifications];
    [[ContentManager sharedInstance]endGenerateNotification];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[coreDataHelper saveContext];
    NSLog(@"foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    isBackground = NO;
    if(viewController!=nil)
    {
        [viewController reloadData];
    }
    [[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
    [[ContentManager sharedInstance]beginGenerateNotification];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    isTerminated = YES;
    [contentManager stopFeedingContent];
    [coreDataHelper saveContext];
}


@end
