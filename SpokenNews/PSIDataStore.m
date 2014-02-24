//
//  PSIDataStore.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 14/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "PSIDataStore.h"
#import "PSIHKCoordConvertor.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

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
        [self parseParkList];
    }
    return self;
}

-(void)parseParkList{
    self.carParkList = [[NSMutableArray alloc]init];
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"car_park" ofType:@"plist"];
    NSArray *arr = [[NSArray alloc]initWithContentsOfFile:filePath];
    //NSLog(@"Gas Station List: %@", arr);
    for(NSDictionary *dict in arr){
        ParkMapItem *parkMapItem = [[ParkMapItem alloc]init];
        
        [parkMapItem setName:[dict objectForKey:@"name"]];
        [parkMapItem setAddr:[dict objectForKey:@"addr"]];
        [parkMapItem setDistrict:[dict objectForKey:@"district"]];
        [parkMapItem setLat:[[dict objectForKey:@"lat"]doubleValue]];
        [parkMapItem setLng:[[dict objectForKey:@"lng"]doubleValue]];
        [parkMapItem setTitle:[dict objectForKey:@"name"]];
        [parkMapItem setCoordinate:CLLocationCoordinate2DMake(parkMapItem.lat, parkMapItem.lng)];
        
        [self.carParkList addObject:parkMapItem];
    }
    arr = nil;
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
            [camMapItem setSerial:[subArr objectAtIndex:0]];
            [camMapItem setCamDescription:[subArr objectAtIndex:2]];
            [self.trafficCamList addObject:camMapItem];
        }
    }
}

-(CamMapItem*)getNearestTrafficCam:(CLLocation*)location{
    double minDistance = -1;
    double minDistanceWithBearing = -1;
    CamMapItem *nearestCam;
    CamMapItem *nearestCamWithBearing;
    
    double heading = [[ContentManager sharedInstance]heading];
    double view_angle = 100;
    double left_heading = fmod(((heading-view_angle/2)+360), 360);
    double right_heading = fmod(((heading+view_angle/2)+360), 360);
    
    NSLog(@"range %.2f < %.2f < %.2f", left_heading, heading, right_heading);
    
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
            
            
            //handle bearing
            double bearing = angleFromCoordinate(location.coordinate.latitude, location.coordinate.longitude,
                                                 nearestCam.lat, nearestCam.lng);
            BOOL isBearingOK= NO;
            if(fabs(right_heading - left_heading) > view_angle)
            {
                if( bearing > right_heading || bearing < left_heading)
                {
                    isBearingOK = YES;
                }
            } else if( bearing < right_heading && bearing > left_heading)
            {
                isBearingOK = YES;
            }
            if(isBearingOK)
            {
                if(minDistanceWithBearing == -1)
                {
                    CLLocation *loc = [[CLLocation alloc]initWithLatitude:mapItem.lat longitude:mapItem.lng];
                    minDistanceWithBearing = [location distanceFromLocation:loc];
                    nearestCamWithBearing = mapItem;
                } else {
                    CLLocation *loc = [[CLLocation alloc]initWithLatitude:mapItem.lat longitude:mapItem.lng];
                    double distance = [location distanceFromLocation:loc];
                    if(distance < minDistanceWithBearing)
                    {
                        minDistanceWithBearing = distance;
                        nearestCamWithBearing = mapItem;
                    }
                }
            }
        }
    }
    
//    NSLog(@"user bearing: %.2f", [location course]);
//    NSLog(@"bearing: %.2f",
    if(nearestCamWithBearing != nil)
    {
        return nearestCamWithBearing;
    }
    return nearestCam;
}

double angleFromCoordinate(double lat1, double long1, double lat2, double long2){
    /*
    CLLocationCoordinate2D coord1 = nearestAnnotation.coordinate;
    CLLocationCoordinate2D coord2 = userLocation.coordinate;
    
    CLLocationDegrees deltaLong = coord2.longitude - coord1.longitude;
    CLLocationDegrees yComponent = sin(deltaLong) * cos(coord2.latitude);
    CLLocationDegrees xComponent = (cos(coord1.latitude) * sin(coord2.latitude)) - (sin(coord1.latitude) * cos(coord2.latitude) * cos(deltaLong));
    
    CLLocationDegrees radians = atan2(yComponent, xComponent);
    CLLocationDegrees degrees = RAD_TO_DEG(radians) + 360;
    */
//    
//    if(isDebug)
//        NSLog(@" the degress is = %f",fmod(degrees, 360));
    
    double dLon = (long2-long1);
    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double brng = atan2(y, x);
    brng = RADIANS_TO_DEGREES(brng);
    brng = fmod((brng+360), 360); //(brng+360)%360;
    brng = 360 - brng;
    return brng;
}

-(NSArray*)getNearestGasStations:(CLLocation*)location{
    int size = 5;
    
    CLLocation *theLocation = location;
    if(theLocation == nil)
    {
        theLocation = [[ContentManager sharedInstance]requestLastLocation];
    }
    
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
                
                if([theLocation distanceFromLocation:loc1] >
                   [theLocation distanceFromLocation:loc2]){
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

-(NSArray*)getNearestParkingLot:(CLLocation*)location{
    int size = 5;
    
    CLLocation *theLocation = location;
    if(theLocation == nil)
    {
        theLocation = [[ContentManager sharedInstance]requestLastLocation];
    }
    
    NSMutableArray *nearestParkingLotList = [[NSMutableArray alloc]init];
    for(ParkMapItem *mapItem in self.carParkList)
    {
        if([nearestParkingLotList count] == 0)
        {
            [nearestParkingLotList addObject:mapItem];
        } else {
            for(int i =0; i< [nearestParkingLotList count]; i++)
            {
                //in nearestgasstation
                ParkMapItem *mapItemInArr = [nearestParkingLotList objectAtIndex:i];
                CLLocation *loc1 = [[CLLocation alloc]initWithLatitude:mapItemInArr.lat longitude:mapItemInArr.lng];
                //in newgatstation
                CLLocation *loc2 = [[CLLocation alloc]initWithLatitude:mapItem.lat longitude:mapItem.lng];
                
                if([theLocation distanceFromLocation:loc1] >
                   [theLocation distanceFromLocation:loc2]){
                    [nearestParkingLotList insertObject:mapItem atIndex:i];
                    if([nearestParkingLotList count]>size)
                    {
                        [nearestParkingLotList removeLastObject];
                    }
                    break; //should be sorted from closest -> 5th most closest
                }
            }
        }
    }
    return nearestParkingLotList;
}

@end
