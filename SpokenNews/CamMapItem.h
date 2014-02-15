//
//  CamMapItem.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 14/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CamMapItem : NSObject <MKAnnotation>
@property (assign) double lat;
@property (assign) double lng;
@property (nonatomic, copy) NSString *camDescription;
@property (nonatomic, copy) NSString *webAddress;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
@end
