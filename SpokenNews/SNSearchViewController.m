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
#import "JNJGoogleMapsActivity.h"
#import "AppleMapsActivity.h"

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

BOOL isFirst;
-(void)viewDidAppear:(BOOL)animated{
    isFirst = NO;
    [super viewDidAppear:animated];
    //NSArray *gasStationList = [[PSIDataStore sharedInstance]gasStationList];
    if(searchType==0)
    {
        searchResultArr = [[PSIDataStore sharedInstance]getNearestParkingLot:myMapView.userLocation.location];
    } else {
        searchResultArr = [[PSIDataStore sharedInstance]getNearestGasStations:myMapView.userLocation.location];
    }
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

    NSString *strToSpeak;
    if(!isFirst)
    {
        isFirst = YES;
        if(searchType == 0)
        {
            strToSpeak = [NSString stringWithFormat:@"現正顯示最近你的 5 個停車場，第一個係 %@，係 %@", [(id)[searchResultArr objectAtIndex:currentPage]name],
                          [(id)[searchResultArr objectAtIndex:currentPage]addr]];
        } else {
            strToSpeak = [NSString stringWithFormat:@"現正顯示最近你的 5 個油站，第一個係 %@，係 %@", [(id)[searchResultArr objectAtIndex:currentPage]name],
                          [(id)[searchResultArr objectAtIndex:currentPage]addr]];
        }
    } else {
        strToSpeak = [NSString stringWithFormat:@"%@，係 %@", [(id)[searchResultArr objectAtIndex:currentPage]name],
                      [(id)[searchResultArr objectAtIndex:currentPage]addr]];
    }

    
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

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    NSLog(@"tapped");
    if([view.annotation isKindOfClass:[GasMapItem class]]||[view.annotation isKindOfClass:[ParkMapItem class]])
    {
        GasMapItem *item = [view annotation];
        NSURL *testURL = [NSURL URLWithString:@"comgooglemaps-x-callback://"];
        if ([[UIApplication sharedApplication] canOpenURL:testURL]) {
            [[SpeakManager sharedInstance]forceSpeak:@"請選擇導航 App"];
            //NSLog(@"show google map option");
            JNJGoogleMapsActivity *googleMapsActivity = [[JNJGoogleMapsActivity alloc] init];
            googleMapsActivity.latitude = [NSNumber numberWithDouble:item.lat];//@(35.7719);
            googleMapsActivity.longitude = [NSNumber numberWithDouble:item.lng];//@(-78.6389);
            googleMapsActivity.mapMode = JNJGoogleMapsMapMode.standard;
            googleMapsActivity.directionMode = JNJGoogleMapsDirectionMode.driving;
            
            AppleMapsActivity* appleMapsActivity = [[AppleMapsActivity alloc]init];
            appleMapsActivity.latitude = [NSNumber numberWithDouble:item.lat];//@(35.7719);
            appleMapsActivity.longitude = [NSNumber numberWithDouble:item.lng];//@(35.7719);
            
            UIActivityViewController *viewController = [[UIActivityViewController alloc] initWithActivityItems:@[] applicationActivities:@[appleMapsActivity, googleMapsActivity]];
            [self presentViewController:viewController animated:YES completion:nil];
            
        } else {
            MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:item.coordinate addressDictionary:nil];
            MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placemark];
            //open map in ios map and do navigation
            [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving}];
        }
    }
}


-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKAnnotationView *annotationView;
    if([annotation isKindOfClass:[GasMapItem class]]||[annotation isKindOfClass:[ParkMapItem class]])
    {
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"PinItem"];
        if(annotationView == nil)
        {
            annotationView = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"PinItem"];
            [annotationView setCanShowCallout:YES];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(0,0,44.5, 44.5)];
            //[btn setImage:[UIImage imageNamed:@"navBtn"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"navBtn"] forState:UIControlStateNormal];
            //[btn setTitle:@"hihi" forState:UIControlStateNormal];
            [annotationView setLeftCalloutAccessoryView:btn];
        }
    } else if([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else {
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"OtherItem"];
        if(annotationView == nil)
        {
            annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"OtherItem"];
        }
    }
    return annotationView;
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
