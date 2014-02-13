//
//  NewsViewController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 1/7/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import "NewsViewController.h"
#import "AppDelegate.h"
#import "NewsData.h"
#import "NewsDataCell.h"
#import <QuartzCore/QuartzCore.h>
#import "GlobalHeader.h"

@interface NewsViewController ()

@end

@implementation NewsViewController
@synthesize fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    viewController = self;
    
    prefStore = [PrefStore sharedInstance];
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self loadPreferences];
    [infoView removeFromSuperview];
    
    //init map view
    [self initMapView];
    [self dropPinOnMapView];
    
    
    //app shadow on view
    [self applyShadow:speedCamView];
    [self applyShadow:infoContent];
    
    //app apply visual effect
    //[self applyMotionEffect:map];
}

- (void)applyMotionEffect:(UIView*)view
{
//    view.layer.transform
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    xAxis.minimumRelativeValue = [NSNumber numberWithFloat:-15.0];
    xAxis.maximumRelativeValue = [NSNumber numberWithFloat:15.0];
    
    
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    yAxis.minimumRelativeValue = [NSNumber numberWithFloat:15.0];
    yAxis.maximumRelativeValue = [NSNumber numberWithFloat:-15.0];
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[yAxis,xAxis];
    
    [view addMotionEffect:group];
}

- (void)applyShadow:(UIView*)inView
{
    [inView setClipsToBounds:NO];
    //[inView.layer setCornerRadius:2.5f];
    [inView.layer setShadowOffset:CGSizeMake(0, 1)];
    [inView.layer setShadowColor:[[UIColor darkGrayColor] CGColor]];
    [inView.layer setShadowRadius:3.5f];
    [inView.layer setShadowOpacity:0.75f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!isFirstLaunch)
    {
        NSLog(@"do init works");
        isFirstLaunch = YES;
        //[(AppDelegate*)[[UIApplication sharedApplication]delegate]doInitDB];
        //[(AppDelegate*)[[UIApplication sharedApplication]delegate]doInitWork];
        
        NSError *error = nil;
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.newsTableView setScrollsToTop:YES];
        if(isDebug)
            NSLog(@"the count is = %lu",(unsigned long)[fetchedResultsController.fetchedObjects count]);
    }
    
    //todo
    if([[NSUserDefaults standardUserDefaults]objectForKey:@"showtutorial"] == nil)
    {
        [self performSegueWithIdentifier:@"showtutorial" sender:nil];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"showtutorial"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}

- (void)loadPreferences{
    [speakSwitch setOn:prefStore.isDriving];
    [newsSwitch setOn:prefStore.isUpdateNews];
    if(prefStore.gpsType == kCLLocationAccuracyBestForNavigation) {
        [gpsSegment setSelectedSegmentIndex:0];
    } else if(prefStore.gpsType == kCLLocationAccuracyBest) {
        [gpsSegment setSelectedSegmentIndex:1];
    } else {
        [gpsSegment setSelectedSegmentIndex:2];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - map view

- (void) disableScrollsToTopPropertyOnAllSubviewsOf:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            ((UIScrollView *)subview).scrollsToTop = NO;
        }
        [self disableScrollsToTopPropertyOnAllSubviewsOf:subview];
    }
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    //    if (mapView.selectedAnnotations.count == 0)
    //        [self updateDistanceToAnnotation:nil];
    //    else
    //        [self updateDistanceToAnnotation:[mapView.selectedAnnotations objectAtIndex:0]];
    
    MKCoordinateRegion theRegion;
    theRegion.center=userLocation.coordinate;
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.009;
	theSpan.longitudeDelta = 0.009;
	theRegion.span = theSpan;
    
    //    NSLog(@"%.1f %.1f %.1f %.1f", theRegion.span.latitudeDelta,
    //          theRegion.span.longitudeDelta,
    //          theRegion.center.latitude, theRegion.center.longitude);
    
    if(theRegion.span.latitudeDelta == 0 || theRegion.span.latitudeDelta == 0 ||
       theRegion.center.latitude== -180 || theRegion.center.longitude == -180)
    {
        
    } else {
        [map setRegion:theRegion];
    }
    
    
    [self findNearAnnotation];
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //    [self updateDistanceToAnnotation:view.annotation];
}

-(void)findNearAnnotation{
    NSMutableArray *distances = [[NSMutableArray alloc]init];
    NSMutableDictionary *disDict = [[NSMutableDictionary alloc]init];
    
    CLLocation *pinCCLocation;
    CLLocationDistance distance;
    CLLocation *userLocation = [[CLLocation alloc]
                                initWithLatitude:map.userLocation.coordinate.latitude
                                longitude:map.userLocation.coordinate.longitude];
    for (id <MKAnnotation> annotation in map.annotations) {
        pinCCLocation = [[CLLocation alloc]
                         initWithLatitude:annotation.coordinate.latitude
                         longitude:annotation.coordinate.longitude];
        distance = [pinCCLocation distanceFromLocation:userLocation];
        //NSLog(@"the title is =%@",annotation.title);
        [distances addObject:[NSNumber numberWithDouble:distance]];
        [disDict setObject:annotation forKey:[[NSNumber numberWithDouble:distance]stringValue]];
    }
    NSArray * sortedNum = [distances sortedArrayUsingSelector:@selector(compare:)];
    // for (id obj in sortedNum) NSLog(@"sortedNum:%@", obj);
    
    double dist = [[sortedNum objectAtIndex:1]doubleValue];
    if(dist > 1000)
        distanceLabel.text = [NSString stringWithFormat:@"%.1f km",dist/1000];
    else
        distanceLabel.text = [NSString stringWithFormat:@"%.1f m", dist];
    id<MKAnnotation> nearestAnnotation = [disDict objectForKey:[[sortedNum objectAtIndex:1]stringValue]];
    if([nearestAnnotation respondsToSelector:@selector(title)])
    {
        pinLocation.text = nearestAnnotation.title;
    }
    
    
    
    //    CLLocationCoordinate2D coord1 = nearestAnnotation.coordinate;
    //	CLLocationCoordinate2D coord2 = userLocation.coordinate;
    //
    //	CLLocationDegrees deltaLong = coord2.longitude - coord1.longitude;
    //	CLLocationDegrees yComponent = sin(deltaLong) * cos(coord2.latitude);
    //	CLLocationDegrees xComponent = (cos(coord1.latitude) * sin(coord2.latitude)) - (sin(coord1.latitude) * cos(coord2.latitude) * cos(deltaLong));
    //
    //	CLLocationDegrees radians = atan2(yComponent, xComponent);
    //	CLLocationDegrees degrees = RAD_TO_DEG(radians) + 360;
	
    //NSLog(@" the degress is = %f",fmod(degrees, 360));
    
    
}

-(void)initMapView{
    [map setMapType:MKMapTypeStandard];
    [map setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    [map setDelegate:self];
}

-(void)dropPinOnMapView{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"StationarySpeedRadar" ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    kmlParser = [[KMLParser alloc] initWithURL:url];
    [kmlParser parseKML];
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    NSArray *overlays = [kmlParser overlays];
    [map addOverlays:overlays];
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    NSArray *annotations = [kmlParser points];
    [map addAnnotations:annotations];
    
    // Walk the list of overlays and annotations and create a MKMapRect that
    // bounds all of them and store it into flyTo.
    MKMapRect flyTo = MKMapRectNull;
    for (id <MKOverlay> overlay in overlays) {
        if (MKMapRectIsNull(flyTo)) {
            flyTo = [overlay boundingMapRect];
        } else {
            flyTo = MKMapRectUnion(flyTo, [overlay boundingMapRect]);
        }
    }
    
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
        if (MKMapRectIsNull(flyTo)) {
            flyTo = pointRect;
        } else {
            flyTo = MKMapRectUnion(flyTo, pointRect);
        }
    }
    
    // Position the map so that all overlays and annotations are visible on screen.
    map.visibleMapRect = flyTo;
    
}

//- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
//{
//    //return [kmlParser viewForOverlay:overlay];
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    return [kmlParser viewForAnnotation:annotation];
}


#pragma mark - table view & core data

-(void)reloadData{
    //    [map setUserTrackingMode:MKUserTrackingModeFollowWithHeading];
    [fetchedResultsController performFetch:nil];
    [self.newsTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [fetchedResultsController.fetchedObjects count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //return 373;
    if([UIScreen mainScreen].bounds.size.height > 480)
    {
        if(isDebug)
            NSLog(@"iphone 4 inch");
        return 395;
    } else {
        if(isDebug)
            NSLog(@"iphone 3.5 inch");
        return 307;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //nothing
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    NewsDataCell *cell = (NewsDataCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[NewsDataCell alloc] init];
    }
    
    NewsData *dataObject = [[fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row];
    //    cell.textLabel.text = dataObject.content;
    [[((NewsDataCell*)cell) textView]setScrollsToTop:NO];
    [[((NewsDataCell*)cell) textView]setText:dataObject.content];
    
    [self applyShadow:[((NewsDataCell*)cell) bgView]];
//    [[((NewsDataCell*)cell) bgImageView]setBackgroundColor:[UIColor clearColor]];
    
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //    NSString *strDate = [dateFormatter stringFromDate:dataObject.timestamp];
    //    cell.textLabel.text = strDate;
    return cell;
}


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity;
	// Edit the entity name as appropriate.
    
    entity = [NSEntityDescription entityForName:@"NewsData" inManagedObjectContext:[coreDataHelper managedObjectContext]];
    
	[fetchRequest setEntity:entity];
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	
    
	[fetchRequest setSortDescriptors:sortDescriptors];
    
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[coreDataHelper managedObjectContext] sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
    
	return fetchedResultsController;
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSLog(@"here");
    if(type == NSFetchedResultsChangeInsert)
    {
        NSLog(@"try insert row");
        [self.newsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        if(noNewsContainerView.alpha > 0)
        {
            [UIView animateWithDuration:0.3f animations:^(void){
                [noNewsContainerView setAlpha:0.0f];
            }];
        }
        
    } else if(type == NSFetchedResultsChangeDelete)
    {
        [self.newsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationBottom];
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.newsTableView endUpdates];
}

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if([self.newsTableView numberOfRowsInSection:0] > 0)
        [self.newsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [self.newsTableView beginUpdates];
}



#pragma mark - ui events
-(IBAction)optionChanged:(id)sender{
    switch([sender tag])
    {
        case 0:
            prefStore.isDriving = [speakSwitch isOn];
            if(prefStore.isDriving == YES)
            {
                //[((AppDelegate*)[[UIApplication sharedApplication]delegate]) speakActiviated];
            }
            [[NSUserDefaults standardUserDefaults]setBool:prefStore.isDriving forKey:@"isSpeak"];
            break;
        case 1:
            prefStore.isUpdateNews = [newsSwitch isOn];
            [[NSUserDefaults standardUserDefaults]setBool:prefStore.isUpdateNews forKey:@"isUpdateNews"];
            break;
        case 2:
            if(gpsSegment.selectedSegmentIndex == 0){
                prefStore.gpsType = kCLLocationAccuracyBestForNavigation;
            } else if(gpsSegment.selectedSegmentIndex == 1){
                prefStore.gpsType = kCLLocationAccuracyBest;
            } else if(gpsSegment.selectedSegmentIndex == 2){
                prefStore.gpsType = kCLLocationAccuracyNearestTenMeters;
            }
            //[((AppDelegate*)[[UIApplication sharedApplication]delegate]) updateGPSType];
            [[NSUserDefaults standardUserDefaults]setDouble:prefStore.gpsType forKey:@"gpsType"];
            break;
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(IBAction)infoBtnClicked:(id)sender{
    
    if(!isShowSetting)
    {
        NSLog(@"show setting");
        isShowSetting = !isShowSetting;
        UIView *startView = isShowSetting?newsView:infoView;
        UIView *endView = isShowSetting?infoView:newsView;
        UIViewAnimationOptions op = isShowSetting?UIViewAnimationOptionTransitionFlipFromLeft:UIViewAnimationOptionTransitionFlipFromLeft;
        
        speedCamVerticalSpace.constant = -200;
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState animations:^(void)
         {
             [self.view layoutIfNeeded];
         } completion:^(BOOL completed){
             
             if([InvivoDeviceUtility deviceSupportAutoLayout])
             {
                 //verticalSpaceRootViewNewsView
                 [animateView addSubview:endView];
                 [animateView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"|[endView]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(animateView, endView)]];
                 [animateView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[endView]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(animateView, endView)]];
             }
             
             [UIView transitionFromView:startView toView:endView duration:0.5 options:op completion:^(BOOL isComplete){
                 [startView removeFromSuperview];
             }];
         }];
    } else {
        NSLog(@"no show show setting");
        isShowSetting = !isShowSetting;
        
        
        UIView *startView = isShowSetting?newsView:infoView;
        UIView *endView = isShowSetting?infoView:newsView;
        UIViewAnimationOptions op = isShowSetting?UIViewAnimationOptionTransitionFlipFromLeft:UIViewAnimationOptionTransitionFlipFromLeft;
        
        if([InvivoDeviceUtility deviceSupportAutoLayout])
        {
            //[endView setHidden:YES];
            [animateView addSubview:endView];
            [animateView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"|[endView]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(animateView, endView)]];
            [animateView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[endView]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(animateView, endView)]];
        }
        if([InvivoDeviceUtility deviceSupportAutoLayout])
        {
            //[endView setHidden:YES];
            [animateView addSubview:endView];
            [animateView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"|[endView]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(animateView, endView)]];
            [animateView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[endView]|" options: 0 metrics: nil views: NSDictionaryOfVariableBindings(animateView, endView)]];
        }
        
        [UIView transitionFromView:startView toView:endView duration:0.5 options:op completion:^(BOOL isComplete){
            
            [startView removeFromSuperview];
            //            [shadow1 setAlpha:1.0];
            //            [shadow2 setAlpha:1.0];
            NSLog(@"complete");
        }];
        
        speedCamVerticalSpace.constant = 15;
        [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^(void)
         {
             [self.view layoutIfNeeded];
         } completion:^(BOOL completed){
             speedCamVerticalSpace.constant = 10;
             [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionBeginFromCurrentState animations:^(void)
              {
                  [self.view layoutIfNeeded];
              } completion:^(BOOL completed){
                  
                  //[infoScrollView setContentSize:CGSizeMake(286,315)];
                  //[infoScrollView setContentOffset:CGPointMake(0,0)];
              }];
         }];
    }
}

@end
