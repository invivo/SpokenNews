//
//  GasMapItem.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 15/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GasMapItem : NSObject<MKAnnotation>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *addr;
@property (nonatomic, copy) NSString *district;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

@property (assign) double lat;
@property (assign) double lng;



@end
