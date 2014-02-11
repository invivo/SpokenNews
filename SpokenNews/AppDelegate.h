//
//  AppDelegate.h
//  SpokenNews
//
//  Created by Kwok Yu Ho on 11/1/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MapKit/MapKit.h>
#import "ESpeakEngine.h"
#import "ContentManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UINavigationControllerDelegate>
{
    CLLocationManager *manager;
    CLLocationCoordinate2D lastestCamCoord;
    PrefStore *prefStore;
    ContentManager *contentManager;
    //SpeakManager *speakManager;
}
-(void)doInitDB;
-(void)doInitWork;

@property (strong, nonatomic) UIWindow *window;

@end
