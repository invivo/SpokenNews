//
//  SNNewsListController.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "GlobalHeader.h"

@interface SNNewsListController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
-(void)reloadData;
@property (strong, nonatomic) IBOutlet UITableView *newsTableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end
