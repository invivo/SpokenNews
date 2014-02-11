//
//  CoreDataHelper.h
//  SpokenNews
//
//  Created by Kwok Yu Ho on 13/1/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataHelper : NSObject
- (void)saveContext;
- (BOOL)isDataExist:(NSString*)str;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end
