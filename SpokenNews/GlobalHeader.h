//
//  GlobalHeader.h
//  SpokenNews
//
//  Created by Kwok Yu Ho on 11/1/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//
#import <Foundation/Foundation.h>
//#import "ESpeakEngine.h"
#import "CoreDataHelper.h"
#import "KMLParser.h"
#import "NewsViewController.h"
#import "NativeTTS.h"
#import "SpokenNewsViewController.h"

#ifndef SpokenNews_GlobalHeader_h
#define SpokenNews_GlobalHeader_h

BOOL isDebug;

SpokenNewsViewController *spokenNewsVC;

NewsViewController *viewController;
KMLParser *kmlParser;

//NSMutableArray *speakQueue;

CoreDataHelper *coreDataHelper;

//ESpeakEngine * engine;
//NativeTTS *mEngine;

BOOL isBackground;
BOOL isTerminated;

int backgroundTask;
#endif


