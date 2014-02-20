//
//  AppleMapsActivity.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 19/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "AppleMapsActivity.h"

NSString * const kAppleActivityTypeOpenInAppleMaps = @"AppleActivityTypeOpenInAppleMaps";
NSString * const kAppleMapsActivityTitle = @"Open in Maps";
NSString * const kAppleMapsActivityMaskImageName = @"appleMap";

@implementation AppleMapsActivity

#pragma mark - UIActivity

- (NSString *)activityType
{
	return kAppleActivityTypeOpenInAppleMaps;
}

- (NSString *)activityTitle
{
	return kAppleMapsActivityTitle;
}

- (UIImage *)activityImage
{
	return [UIImage imageNamed:kAppleMapsActivityMaskImageName];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
	return (self.latitude!=nil && self.longitude !=nil);
}

- (void)performActivity
{
	BOOL didFinish = NO;
	
	if(self.latitude != nil && self.longitude != nil)
    {
        didFinish = YES;
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([self.latitude doubleValue],
                                                                       [self.longitude doubleValue]);
        MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placemark];
        //open map in ios map and do navigation
        [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
    }
    
    [self activityDidFinish:didFinish];
}


@end
