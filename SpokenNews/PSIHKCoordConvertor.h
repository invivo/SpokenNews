//
//  PSIHKCoordConvertor.h
//  MyLibrarian
//
//  Created by Yu Ho Kwok on 2/2/14.
//  Copyright (c) 2014 invivo interactive limited. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef double (^conversionBlock) (double);
@interface PSIHKCoordConvertor : NSObject

+(double)doBisectIterWithF:(conversionBlock)f X1:(double)x1 X2:(double)x2 withEpsilon:(double)epsilon;
+(double)getMedianDist:(double)lat;

//input array of NSNumber
+(NSArray*)convertHK80GridToCartesian:(NSArray*)grid;
@end
