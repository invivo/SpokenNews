//
//  ContentManager.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 8/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "ContentManager.h"
#import "NewsData.h"
#import "TFHpple.h"

#define RAD_TO_DEG(r) ((r) * (180 / M_PI))
static ContentManager *manager;
@implementation ContentManager

+(ContentManager*)sharedInstance{
    if(manager==nil)
    {
        manager = [[ContentManager alloc]init];
    }
    return manager;
}

-(id)init{
    self = [super init];
    if(self)
    {
        speakManager = [SpeakManager sharedInstance];
        prefStore = [PrefStore sharedInstance];
        manager = [[CLLocationManager alloc]init];
        
        speakObjQueue = [[NSMutableArray alloc]init];
        
        //load xml
        NSString *path = [[NSBundle mainBundle] pathForResource:@"StationarySpeedRadar" ofType:@"kml"];
        NSURL *url = [NSURL fileURLWithPath:path];
        kmlParser = [[KMLParser alloc] initWithURL:url];
        [kmlParser parseKML];
        
        self.heading = -2036;
    }
    return self;
}

-(void)startFeedingContent{
    
    isDebug = YES;
    if(isDebug)
        NSLog(@"startFeedingContent");
    
    isTerminated = NO;
    manager.delegate = self;
    manager.desiredAccuracy = prefStore.gpsType;
    [manager startUpdatingLocation];
    [manager startUpdatingHeading];
    
    [speakManager enableDriving:YES];
    
    
    [self handleContentThread];
    [self handleSpeakThread];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusNotDetermined ||
       status == kCLAuthorizationStatusRestricted)
    {
        if(spokenNewsVC!=nil)
        {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"尚未啟動定位功能"
                                                               message:@"如要啟動自動更新功能，請將 設定 > 穩私 > 定位服務 > 定位服務 及 Spoken News 旁的開關設定為「開」。"
                                                              delegate:nil
                                                     cancelButtonTitle:@"明白"
                                                     otherButtonTitles: nil];
            [alertView show];
            [spokenNewsVC stopFeedingNews];
        }
    } else {
        if(isDebug) NSLog(@"Authorized");
    }
}

-(void)stopFeedingContent{
    [manager stopUpdatingLocation];
    [manager stopUpdatingHeading];
    isTerminated = YES;
    if([contentThread isExecuting])
    {
        [contentThread cancel];
    }
    if([speakThread isExecuting])
    {
        [speakThread cancel];
    }
    [speakObjQueue removeAllObjects];
}

-(void)updateGPSType{
    [manager setDesiredAccuracy:prefStore.gpsType];
}

#pragma mark - content processing in foreground & background mode
-(void)enqueueToSpeak:(NSString*)str withPriority:(int)priority{
    SpeakObject *obj = [[SpeakObject alloc]init];
    [obj setText:str];
    [obj setPriority:priority];
    if(priority == 1)
    {
        [speakObjQueue insertObject:obj atIndex:0];
    } else {
        [speakObjQueue addObject:obj];
    }
}

BOOL speakCountMax = 30;
-(void)bgTaskForSpeak{
    @autoreleasepool {
        if(isDebug) NSLog(@"start working speak task");
        while(!isTerminated)
        {
            [NSThread sleepForTimeInterval:1];
            if(!isTerminated)
            {
                if([speakObjQueue count] > 0 && speakCounter < speakCountMax)
                {
                    if([(SpeakObject*)[speakObjQueue objectAtIndex:0]priority] > 0)
                    {
                        if(isDebug) NSLog(@"ContentManager: Speak Urgent Object");
                        speakCounter = 0;
                        [self performSelectorOnMainThread:@selector(speakOnMainThread) withObject:nil waitUntilDone:YES];
                    } else {
                        speakCounter++;
                    }
                } else {
                    if(speakCounter>speakCountMax)
                    {
                        if(isDebug) NSLog(@"ContentManager: Speak News Object");
                        speakCounter = 0;
                        [self performSelectorOnMainThread:@selector(speakOnMainThread) withObject:nil waitUntilDone:YES];
                    } else {
                        speakCounter++;
                    }
                }
            }
        }
    }
}

-(void)speakOnMainThread{
    if([speakManager isAvaiableForSpeaking])
    {
        if(isDebug) NSLog(@"Content Manager: Handle Speak Cycle: %lu", (unsigned long)[speakObjQueue count]);
        if([speakObjQueue count]>0)
        {
            if(![coreDataHelper isDataExist:[(SpeakObject*)[speakObjQueue objectAtIndex:0]text]])
            {
                SpeakObject *speakObj = [speakObjQueue objectAtIndex:0];
                
                if([speakObjQueue count] > 1) {
                    [speakObjQueue removeObjectAtIndex:0];
                } else {
                    [speakObjQueue removeAllObjects];
                }
                
                if(isBackground)
                {
                    if(isDebug) NSLog(@"Content Manager: Show Notification");
                    [self performSelectorOnMainThread:@selector(doLocalPush:)
                                           withObject:[speakObj text]
                                        waitUntilDone:YES];
                }
                
                BOOL isDemo = NO;
                if(!isDemo) [speakManager speak:[speakObj text]];
                
                
                if(speakObj.priority == 0)
                {
                    self.lastNewsString = [speakObj text];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"NewsUpdate"
                                                                       object:self.lastNewsString userInfo:nil];
                    NewsData *obj = [NSEntityDescription insertNewObjectForEntityForName:@"NewsData" inManagedObjectContext:[coreDataHelper managedObjectContext]];
                    [obj setContent:[speakObj text]];
                    [obj setTimestamp:[NSDate date]];
                    [obj setSpoken:[NSNumber numberWithBool:NO]];
                }
            } else {
                if([speakObjQueue count] > 1) {
                    [speakObjQueue removeObjectAtIndex:0];
                } else {
                    [speakObjQueue removeAllObjects];
                }
            }
            if(isDebug) NSLog(@"news last: %lu", (unsigned long)[speakObjQueue count]);
        }
    }
}

BOOL contentCountMax = 180;
-(void)bgTaskForContent{
    @autoreleasepool {
        NSLog(@"ContentManager: Start Working Content Task");
        while(!isTerminated)
        {
            NSLog(@"ContentManager: Downloading Information");
            //    arrayPos = 0;
            // 1
            NSURL *tutorialsUrl = [NSURL URLWithString:@"http://m.rthk.hk/traffic_zh.htm"];
            NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
            
            // 2
            TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
            
            // 3
            //    NSString *tutorialsXpathQueryString = @"//div[@class='entry']/ul/li/a";
            //NewsContentList
            NSString *tutorialsXpathQueryString = @"//div[@class='NewsContentList']/ul/li/a";
            NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
            NSArray *newsArray = [[NSArray alloc]initWithArray:tutorialsNodes];
            [self performSelectorOnMainThread:@selector(updateNewsContentOnMainThread:) withObject:newsArray waitUntilDone:YES];
            
            [NSThread sleepForTimeInterval:180];
        }
    }
}

-(void)updateNewsContentOnMainThread:(NSArray*)newsArray{
    if(isDebug) NSLog(@"ContentManager: update content to news Array");
    
    if(speakObjQueue == nil)
    {
        //init the speakQueue on demand
        speakObjQueue = [[NSMutableArray alloc]init];
    }
    
    for (long i = ([newsArray count]-1); i>=0; i--) {
        TFHppleElement *element = [newsArray objectAtIndex:i];
        
        BOOL isPass = YES;
        //for(NSString *str in speakQueue)
        for(SpeakObject *obj in speakObjQueue)
        {
            if([obj.text isEqualToString:[[element firstChild]content]] ||
               [coreDataHelper isDataExist:[[element firstChild]content]])
            {
                isPass = NO;
            }
        }
        if(isPass)
        {
            if(isDebug) NSLog(@"ContentManager: Enqueue News Data");
            //[speakQueue addObject:[[element firstChild]content]];
            //NSLog(@"%@", [[element firstChild]content]);
            //[speakObjQueue addObject:[[SpeakObject alloc]initWithText:[[element firstChild]content] withPriority:0]];
            [self enqueueToSpeak:[[element firstChild]content] withPriority:0];
        }
    }
}

-(void)findNearSpeedCam:(CLLocation*)userLocation{
    /*
    if(isDebug)
        NSLog(@"Content Manager: Start Finding Near Speed Cam");
     */
    
    if(kmlParser != nil)
    {
        /*
        if(isDebug)
            NSLog(@"Content Manager: Try Finding Speed Cam");
        */
        NSArray *placemarks = [kmlParser placemarks];
        
        
        NSMutableArray *distances = [[NSMutableArray alloc]init];
        NSMutableDictionary *disDict = [[NSMutableDictionary alloc]init];
        
        CLLocation *pinCCLocation;
        CLLocationDistance distance;
        
        for (NSDictionary* p in placemarks) {
            id <MKAnnotation> annotation = [p objectForKey:@"point"];
            pinCCLocation = [[CLLocation alloc]
                             initWithLatitude:annotation.coordinate.latitude
                             longitude:annotation.coordinate.longitude];
            distance = [pinCCLocation distanceFromLocation:userLocation];
            //            NSLog(@"the title is =%@",annotation.title);
            [distances addObject:[NSNumber numberWithDouble:distance]];
            [disDict setObject:p forKey:[[NSNumber numberWithDouble:distance]stringValue]];
        }
        NSArray * sortedNum = [distances sortedArrayUsingSelector:@selector(compare:)];
        // for (id obj in sortedNum) NSLog(@"sortedNum:%@", obj);
        
        double dist = [[sortedNum objectAtIndex:0]doubleValue];
        if(dist > 1000)
        {
            /*
            if(isDebug)
                NSLog(@"%.1f km",dist/1000);
             */
            //distanceLabel.text = [NSString stringWithFormat:@"%.1f km",dist/1000];
        }
        else
        {
            /*
            if(isDebug)
                NSLog(@"%.1f m", dist);
             */
            if(dist < 500)
            {
                id<MKAnnotation> nearestAnnotation = [[disDict objectForKey:[[sortedNum objectAtIndex:0]stringValue]]objectForKey:@"point"];
                
                if(lastestCamCoord.latitude!=nearestAnnotation.coordinate.latitude &&
                   lastestCamCoord.longitude!=nearestAnnotation.coordinate.longitude)
                {
                    lastestCamCoord = nearestAnnotation.coordinate;
                    //[speakManager forceStopSpeaking];
                    
                    //                NSLog(@"within 500m location");
                    NSMutableArray *camArray = [[NSMutableArray alloc]init];
                    NSArray* components = [[[disDict objectForKey:[[sortedNum objectAtIndex:0]stringValue]] objectForKey:@"description"]componentsSeparatedByString:@" "];
                    for(NSString *component in components)
                    {
                        NSArray* subcomponents = [component componentsSeparatedByString:@"："];
                        //                    NSLog(@"%@", [subcomponents objectAtIndex:1]);
                        if(subcomponents.count > 1)
                        {
                            [camArray addObject:
                             [[subcomponents objectAtIndex:1]stringByReplacingOccurrencesOfString:@"\n" withString:@""]
                             ];
                        }
                    }
                    
                    /*
                    NSString *finalString = [NSString stringWithFormat:@"你的五百米範圍內於%@往%@方向近%@有快相機。", [camArray objectAtIndex:1], [camArray objectAtIndex:2], [camArray objectAtIndex:3]];
                    */
                    NSString *finalStringPush = [NSString stringWithFormat:@"你的 500 米範圍內於%@往%@方向近%@有固定式快相機。", [camArray objectAtIndex:1], [camArray objectAtIndex:2], [camArray objectAtIndex:3]];
                    
                    //                    [engine speakAndCache:finalString];
                    //[speakManager speak:finalString];
                    //[speakManager speak:@"請留意車速"];
                    //[speakObjQueue addObject:[[SpeakObject alloc]initWithText:@"請留意車速" withPriority:1]];
                    //[speakObjQueue insertObject:[[SpeakObject alloc]initWithText:@"請留意車速" withPriority:1] atIndex:0];
                    [self enqueueToSpeak:@"請留意車速" withPriority:1];
                    
                    if(isBackground)
                        [self doLocalPush:finalStringPush];
                    
                    if(isGenerateNotification)
                    {
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"SpeedCamDetected" object:nil];
                    }
                }
            }
        }
        id<MKAnnotation> nearestAnnotation = [[disDict objectForKey:[[sortedNum objectAtIndex:0]stringValue]]objectForKey:@"point"];
        //pinLocation.text = nearestAnnotation.title;
        
        
        
        CLLocationCoordinate2D coord1 = nearestAnnotation.coordinate;
        CLLocationCoordinate2D coord2 = userLocation.coordinate;
        
        CLLocationDegrees deltaLong = coord2.longitude - coord1.longitude;
        CLLocationDegrees yComponent = sin(deltaLong) * cos(coord2.latitude);
        CLLocationDegrees xComponent = (cos(coord1.latitude) * sin(coord2.latitude)) - (sin(coord1.latitude) * cos(coord2.latitude) * cos(deltaLong));
        
        CLLocationDegrees radians = atan2(yComponent, xComponent);
        //CLLocationDegrees degrees = RAD_TO_DEG(radians) + 360;
        
        /*
        if(isDebug)
            NSLog(@" the degress is = %f",fmod(degrees, 360));
         */
    }
    
}

#pragma mark - location manager delegate
//handle threading stuff, main the thread
//keep the latest location for checking speedCam location
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [self handleContentThread];
    [self handleSpeakThread];
    [self findNearSpeedCam:[locations lastObject]];
    
    self.lastLocation = [locations lastObject];
    if(isGenerateNotification)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationUpdate"
                                                           object:self.lastLocation];
    }
}

//double heading = -2036;
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    //NSLog(@"heading: %.2f", newHeading.trueHeading);
    if(_heading == -2036)
    {
        _heading  = newHeading.trueHeading;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationUpdate"
                                                           object:self.lastLocation];
    } else {
        if((_heading <= 30 && newHeading.trueHeading >= 330) ||
           (newHeading.trueHeading <= 30 && _heading >= 330))
        {
            if((_heading+newHeading.trueHeading-360)>30)
            {
                _heading  = newHeading.trueHeading;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationUpdate"
                                                                   object:self.lastLocation];
            }
        } else if(fabs(_heading - newHeading.trueHeading) > 30 )
        {
            _heading  = newHeading.trueHeading;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"LocationUpdate"
                                                               object:self.lastLocation];
        }
    }
    
}

#pragma mark - schedule local notification
-(void)doLocalPush:(NSString*)msg{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    
    localNotif.alertBody = msg;
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
    
    localNotif.soundName = nil;
    localNotif.applicationIconBadgeNumber = 0;
    
    NSDictionary *infoDict = nil;
    localNotif.userInfo = infoDict;
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

#pragma mark - threading stuff
- (void)handleSpeakThread{
    
    if(speakThread == nil)
    {
        if(isDebug) NSLog(@"ContentManager: creating SpeakThread");
        speakThread = [[NSThread alloc]initWithTarget:self selector:@selector(bgTaskForSpeak) object:nil];
        [speakThread start];
    } else {
        @try{
            if([speakThread isCancelled] || [speakThread isFinished])
            {
                if(isDebug) NSLog(@"ContentManager: start speakThread");
                [speakThread start];
            }
        }
        @catch(NSException *e){
            if(isDebug) NSLog(@"ContentManager: creating SpeakThread");
            speakThread = [[NSThread alloc]initWithTarget:self selector:@selector(bgTaskForSpeak) object:nil];
            [speakThread start];
        }
    }
}

- (void)handleContentThread{
    if(contentThread == nil)
    {
        if(isDebug) NSLog(@"ContentManager: creating ContentThread");
        contentThread = [[NSThread alloc]initWithTarget:self selector:@selector(bgTaskForContent) object:nil];
        [contentThread start];
    } else {
        @try{
            if([contentThread isCancelled] || [contentThread isFinished])
            {
                if(isDebug) NSLog(@"ContentManager: start ContentThread");
                [contentThread start];
            }
        }
        @catch(NSException *e){
            if(isDebug) NSLog(@"ContentManager: Creating SpeakThread");
            contentThread = [[NSThread alloc]initWithTarget:self selector:@selector(bgTaskForContent) object:nil];
            [contentThread start];
        }
    }
}

-(CLLocation*)requestLastLocation{
    return [manager location];
}

-(void)beginGenerateNotification{
    isGenerateNotification = YES;
}
-(void)endGenerateNotification {
    isGenerateNotification = NO;
}

@end
