//
//  AnnotationData.h
//  SpokenNews
//
//  Created by Roy Lam on 6/2/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface AnnotationData : NSObject

@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) id<MKAnnotation> annotation;

@end
