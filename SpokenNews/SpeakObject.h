//
//  SpeakObject.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 20/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpeakObject : NSObject
@property (nonatomic, copy) NSString *text;
@property (assign) int priority;
-(SpeakObject*)initWithText:(NSString*)t withPriority:(int)p;
@end
