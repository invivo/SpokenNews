//
//  PSIDataStore.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 14/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "PSIDataStore.h"
#import "PSIHKCoordConvertor.h"

static PSIDataStore* dataStore;
@implementation PSIDataStore
+(PSIDataStore*)sharedInstance{
    if(dataStore==nil)
    {
        dataStore = [[PSIDataStore alloc]init];
    }
    return dataStore;
}

-(id)init{
    self = [super init];
    if(self)
    {
        [self parseCamList];
        [self parseGasList];
    }
    return self;
}

-(void)parseGasList{
    self.gasStationList = [[NSMutableArray alloc]init];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"gas_station" ofType:@"plist"];
    NSArray *arr = [[NSArray alloc]initWithContentsOfFile:filePath];
    //NSLog(@"Gas Station List: %@", arr);
    for(NSDictionary *dict in arr){
        GasMapItem *gasMapItem = [[GasMapItem alloc]init];
        
        [gasMapItem setName:[dict objectForKey:@"name"]];
        [gasMapItem setAddr:[dict objectForKey:@"addr"]];
        [gasMapItem setDistrict:[dict objectForKey:@"district"]];
        [gasMapItem setLat:[[dict objectForKey:@"lat"]doubleValue]];
        [gasMapItem setLng:[[dict objectForKey:@"lng"]doubleValue]];
        [gasMapItem setTitle:[dict objectForKey:@"name"]];
        [gasMapItem setCoordinate:CLLocationCoordinate2DMake(gasMapItem.lat, gasMapItem.lng)];
        
        [self.gasStationList addObject:gasMapItem];
    }
    arr = nil;
}

-(void)parseCamList{
    self.trafficCamList = [[NSMutableArray alloc]init];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"cam_chi" ofType:@"csv"];
    NSString *str = [[NSString alloc]initWithData:[NSData dataWithContentsOfFile:filePath] encoding:NSUTF8StringEncoding];
    NSArray *arr = [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for(int i =1; i<[arr count]; i++)
    {
        NSString* subStr = [arr objectAtIndex:i];
        NSArray *subArr = [subStr componentsSeparatedByString:@","];
        if([subArr count]>1)
        {
            CamMapItem *camMapItem = [[CamMapItem alloc]init];
            [camMapItem setWebAddress:[subArr objectAtIndex:5]];
            [camMapItem setTitle:[subArr objectAtIndex:2]];
            
            NSNumber *northing = [NSNumber numberWithDouble:[[subArr objectAtIndex:4]doubleValue]];
            NSNumber *easting = [NSNumber numberWithDouble:[[subArr objectAtIndex:3]doubleValue]];
            NSArray *latLng = [PSIHKCoordConvertor convertHK80GridToCartesian:@[northing, easting]];
            
            double lat = [[latLng objectAtIndex:0]doubleValue];
            double lng = [[latLng objectAtIndex:1]doubleValue];
            [camMapItem setCoordinate:CLLocationCoordinate2DMake(lat, lng)];
            [camMapItem setLat:lat];
            [camMapItem setLng:lng];
            [camMapItem setCamDescription:[subArr objectAtIndex:2]];
            [self.trafficCamList addObject:camMapItem];
        }
    }
}

-(CamMapItem*)getNearestTrafficCam:(CLLocation*)location{
    double minDistance = -1;
    CamMapItem *nearestCam;
    for(CamMapItem *mapItem in self.trafficCamList)
    {
        if(minDistance == -1)
        {
            CLLocation *loc = [[CLLocation alloc]initWithLatitude:mapItem.lat longitude:mapItem.lng];
            minDistance = [location distanceFromLocation:loc];
            nearestCam = mapItem;
        } else {
            CLLocation *loc = [[CLLocation alloc]initWithLatitude:mapItem.lat longitude:mapItem.lng];
            double distance = [location distanceFromLocation:loc];
            if(distance < minDistance)
            {
                minDistance = distance;
                nearestCam = mapItem;
            }
        }
    }
    return nearestCam;
}

-(NSArray*)getNearestGasStations:(CLLocation*)location{
    int size = 5;
    NSMutableArray *nearestGasStationList = [[NSMutableArray alloc]init];
    for(GasMapItem *mapItem in self.gasStationList)
    {
        if([nearestGasStationList count] == 0)
        {
            [nearestGasStationList addObject:mapItem];
        } else {
            for(int i =0; i< [nearestGasStationList count]; i++)
            {
                //in nearestgasstation
                GasMapItem *mapItemInArr = [nearestGasStationList objectAtIndex:i];
                CLLocation *loc1 = [[CLLocation alloc]initWithLatitude:mapItemInArr.lat longitude:mapItemInArr.lng];
                //in newgatstation
                CLLocation *loc2 = [[CLLocation alloc]initWithLatitude:mapItem.lat longitude:mapItem.lng];
                
                if([location distanceFromLocation:loc1] > [location distanceFromLocation:loc2]){
                    [nearestGasStationList insertObject:mapItem atIndex:i];
                    if([nearestGasStationList count]>size)
                    {
                        [nearestGasStationList removeLastObject];
                    }
                    break; //should be sorted from closest -> 5th most closest
                }
            }
        }
    }
    return nearestGasStationList;
}

@end
