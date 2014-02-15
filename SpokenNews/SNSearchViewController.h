//
//  SNSearchViewController.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 15/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ContentManager.h"
#import "PSIDataStore.h"

@interface SNSearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    IBOutlet  MKMapView *myMapView;
    NSArray *searchResultArr;
    
    
    IBOutlet UITableView *_tableView;
    
    IBOutlet UILabel *searchTypeLabel;
}
-(void)setSearchType:(int)type;
@end
