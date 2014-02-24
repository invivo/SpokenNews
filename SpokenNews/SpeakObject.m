//
//  SpeakObject.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 20/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SpeakObject.h"

@implementation SpeakObject
-(SpeakObject*)initWithText:(NSString*)t withPriority:(int)p{
    self = [super init];
    if(self)
    {
        self.text = t;
        self.priority = p;
    }
    return self;
}
@end
