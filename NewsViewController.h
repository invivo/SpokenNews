//
//  NewsViewController.h
//  SpokenNews
//
//  Created by Yu Ho Kwok on 1/7/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KMLParser.h"
#import "PrefStore.h"

@interface NewsViewController : UIViewController<NSFetchedResultsControllerDelegate,UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>
{
    PrefStore *prefStore;
    
    BOOL isFirstLaunch;
    BOOL isShowSetting;
    
    IBOutlet UIView *animateView;
    //info & news view are belongs to animateView
    IBOutlet UIView *infoView;
    IBOutlet UIView *newsView;
    
    IBOutlet UIView *speedCamView;
    IBOutlet UIView *infoContent;
    
    IBOutlet UIView *noNewsContainerView;    
    
    //map
    IBOutlet MKMapView *map;
    
    //setting panel
    IBOutlet UISwitch* speakSwitch;
    IBOutlet UISwitch* newsSwitch;
    IBOutlet UISegmentedControl* gpsSegment;
    
    //for animation
    __weak IBOutlet NSLayoutConstraint *speedCamVerticalSpace;
    
    //pin location stuff
    IBOutlet UILabel *distanceLabel;
    IBOutlet UILabel *directionLabel;
    IBOutlet UILabel *pinLocation;
}

//table view related
-(void)reloadData;
@property (strong, nonatomic) IBOutlet UITableView *newsTableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

//ui event related
-(IBAction)optionChanged:(id)sender;
-(IBAction)infoBtnClicked:(id)sender;
@end
