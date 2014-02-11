//
//  ContentManager.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 8/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeakManager.h"
#import "PrefStore.h"

@protocol ContentManagerDelegate <NSObject>

@end

@interface ContentManager : NSObject <CLLocationManagerDelegate>
{
    SpeakManager *speakManager;
    
    NSThread *speakThread;
    NSThread *contentThread;
    
    CLLocationManager *manager;
    CLLocationCoordinate2D lastestCamCoord;
    
    PrefStore *prefStore;
}

+(ContentManager*)sharedInstance;

-(void)updateGPSType;

-(void)startFeedingContent;
-(void)stopFeedingContent;
@end
