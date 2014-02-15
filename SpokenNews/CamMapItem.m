//
//  CamMapItem.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 14/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "CamMapItem.h"

@implementation CamMapItem
@synthesize title;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}
@end
