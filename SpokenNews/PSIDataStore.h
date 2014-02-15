//
//  PSIDataStore.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 14/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CamMapItem.h"
#import "GasMapItem.h"

@interface PSIDataStore : NSObject
@property (nonatomic, strong) NSMutableArray *trafficCamList;
@property (nonatomic, strong) NSMutableArray *gasStationList;
@property (nonatomic, strong) NSMutableArray *carParkList;

+(PSIDataStore*)sharedInstance;
-(id)init;

-(CamMapItem*)getNearestTrafficCam:(CLLocation*)location;
-(NSArray*)getNearestGasStations:(CLLocation*)location;
@end
