//
//  SNNewsListController.m
//  SpokenNews
//
//  Created by Yu Ho Kwok on 13/2/14.
//  Copyright (c) 2014 invivo interactive. All rights reserved.
//

#import "SNNewsListController.h"
#import "AppDelegate.h"
#import "NewsData.h"
#import "NewsDataCell.h"

@interface SNNewsListController ()

@end

@implementation SNNewsListController
@synthesize fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

BOOL isFirstLaunch;
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(!isFirstLaunch)
    {
        NSLog(@"do init works");
        isFirstLaunch = YES;
//        [(AppDelegate*)[[UIApplication sharedApplication]delegate]doInitDB];
//        [(AppDelegate*)[[UIApplication sharedApplication]delegate]doInitWork];
        
        NSError *error = nil;
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [self.newsTableView setScrollsToTop:YES];
        if(isDebug)
            NSLog(@"the count is = %lu",(unsigned long)[fetchedResultsController.fetchedObjects count]);
    } else {
        [self.newsTableView reloadData];
    }
}

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
    return 184;
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
    [[((NewsDataCell*)cell) textView]setFont:[UIFont systemFontOfSize:22]];
    
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
        
        if(spokenNewsVC != nil)
            [spokenNewsVC releaseScrollViewContentSizeWithAnimation:YES];
        
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"new list controller did load");
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
