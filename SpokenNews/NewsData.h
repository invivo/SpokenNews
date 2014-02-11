//
//  NewsData.h
//  SpokenNews
//
//  Created by Kwok Yu Ho on 13/1/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewsData : NSManagedObject

@property (nonatomic, retain) NSNumber * spoken;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * content;

@end
