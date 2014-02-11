//
//  InvivoVersionUtility.m
//  Unity-iPhone
//
//  Created by Kwok Yu Ho on 8/12/12.
//
//

#import "InvivoDeviceUtility.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@implementation InvivoDeviceUtility
//will be no use later
+(BOOL)deviceSupportStoryBoard{
    return SYSTEM_VERSION_LESS_THAN(@"5.0");
}

+(BOOL)deviceSupportAutoLayout{
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0");
}

+(BOOL)deviceiPad{
    return ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad);
}
@end
