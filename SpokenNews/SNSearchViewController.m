//
//  SNSearchViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 15/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SNSearchViewController.h"
#import "SearchResultCell.h"
#import "SpeakManager.h"
#import <CoreLocation/CoreLocation.h>
@interface SNSearchViewController ()

@end

@implementation SNSearchViewController

int searchType;
-(void)setSearchType:(int)type{
    searchType = type;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    currentPage = 0;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(searchType == 0)
    {
        [searchTypeLabel setText:@"最近停車場"];
    } else {
        [searchTypeLabel setText:@"最近加油站"];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //NSArray *gasStationList = [[PSIDataStore sharedInstance]gasStationList];
    searchResultArr = [[PSIDataStore sharedInstance]getNearestGasStations:myMapView.userLocation.location];
    [myMapView addAnnotations:searchResultArr];
    [_tableView reloadData];
    [self handlePage:currentPage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

int currentPage;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(currentPage*1.0 != (scrollView.contentOffset.y / 140.0))
    {
        currentPage = (int)(scrollView.contentOffset.y / 140.0);
        [self handlePage:currentPage];
    }
//    NSLog(@"page: %.2f", (scrollView.contentOffset.y / 140.0));
}

-(void)handlePage:(int)pageNo{
    
    NSString *strToSpeak = [NSString stringWithFormat:@"%@，係 %@", [(id)[searchResultArr objectAtIndex:currentPage]name],
                            [(id)[searchResultArr objectAtIndex:currentPage]addr]];
    
    [[SpeakManager sharedInstance]forceSpeak:strToSpeak];
    
    CLLocation *loc1 = [[CLLocation alloc]initWithLatitude:[(id)[searchResultArr objectAtIndex:currentPage]lat]
                                                 longitude:[(id)[searchResultArr objectAtIndex:currentPage]lng]];
    double distInKilometer = [loc1 distanceFromLocation:myMapView.userLocation.location]/1000.0;
    // y = dIK
    // 1 = 111

    double degree = ((distInKilometer + ((distInKilometer > 2)?0.5:1)) / 111);
    MKCoordinateRegion region = MKCoordinateRegionMake([(id)[searchResultArr objectAtIndex:currentPage]coordinate],
                                                       MKCoordinateSpanMake(degree, degree));
    [myMapView setRegion:region animated:YES];
    //MKMapCamera *camera  = [[MKMapCamera alloc]init];
    //[camera setPitch:30];
    [myMapView selectAnnotation:[searchResultArr objectAtIndex:currentPage] animated:YES];
    //[myMapView setCamera:camera animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(searchResultArr==nil)
    {
        return 0;
    } else {
        return searchResultArr.count;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SearchResultCell *cell = (SearchResultCell*)[tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    cell.nameLabel.text = [(id)[searchResultArr objectAtIndex:indexPath.row]name];
    cell.addrLabel.text = [(id)[searchResultArr objectAtIndex:indexPath.row]addr];
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
