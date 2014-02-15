//
//  GasMapItem.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 15/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "GasMapItem.h"

@implementation GasMapItem
@synthesize title;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}
@end
