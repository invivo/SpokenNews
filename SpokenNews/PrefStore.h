//
//  PrefStore.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 8/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrefStore : NSObject
@property (assign) BOOL isDriving;
@property (assign) BOOL isUpdateNews;
@property (assign) double gpsType;
-(id)init;
+(PrefStore*)sharedInstance;
@end
