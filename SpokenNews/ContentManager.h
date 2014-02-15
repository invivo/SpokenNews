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
    
    BOOL isGenerateNotification;
}
@property (nonatomic, copy) NSString *lastNewsString;
@property (nonatomic, copy) CLLocation* lastLocation;
+(ContentManager*)sharedInstance;

-(void)updateGPSType;

-(void)beginGenerateNotification;
-(void)endGenerateNotification;

-(void)startFeedingContent;
-(void)stopFeedingContent;
@end
