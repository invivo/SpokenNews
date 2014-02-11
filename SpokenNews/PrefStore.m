//
//  PrefStore.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 8/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "PrefStore.h"
static PrefStore *prefStore;
@implementation PrefStore
-(id)init{
    self=[super init];
    if(self)
    {
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"isDriving"])
        {
            _isDriving = [[[NSUserDefaults standardUserDefaults]objectForKey:@"isDriving"]boolValue];
        } else {
            _isDriving = YES;
        }
        
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"isUpdateNews"])
        {
            _isUpdateNews = [[[NSUserDefaults standardUserDefaults]objectForKey:@"isUpdateNews"]boolValue];
        } else {
            _isUpdateNews = YES;
        }
        
        if([[NSUserDefaults standardUserDefaults]objectForKey:@"gpsType"])
        {
            _gpsType = [[[NSUserDefaults standardUserDefaults]objectForKey:@"gpsType"]doubleValue];
        } else {
            _gpsType = kCLLocationAccuracyBest;
        }
    }
    return self;
}

+(PrefStore*)sharedInstance{
    if(prefStore==nil)
    {
        prefStore = [[PrefStore alloc]init];
    }
    return prefStore;
}
@end
