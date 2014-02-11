//
//  FeedBackViewController.m
//  SpokenNews
//
//  Created by Kwok Yu Ho on 14/2/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import "FeedBackViewController.h"

@interface FeedBackViewController ()
-(BOOL) NSStringIsValidEmail:(NSString *)checkString;
-(BOOL) NSStringIsNotEmpty:(NSString*)checkString;
@end

@implementation FeedBackViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    progressDialog
    = [[UIAlertView alloc]initWithTitle:@"傳送中" message:@" " delegate:self cancelButtonTitle:nil  otherButtonTitles:nil];
    [progressDialog setTag:999];
    progressView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [progressDialog addSubview:progressView];
    [progressView setHidden:NO];
    [progressView setCenter:CGPointMake(142, 70.5)];
    
    
    //[[self navigationController]setNavigationBarHidden:NO animated:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    // Return the number of sections.
//    return 0;
//}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//
//    // Configure the cell...
//
//    return cell;
//}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(IBAction)dismissModel{
    [self.navigationController dismissViewControllerAnimated:YES completion:^(void){}];
}

-(IBAction)sendFeedBack:(id)sender{
    if([self NSStringIsNotEmpty:[nameTextField text]] && [self NSStringIsNotEmpty:[detailTextView text]])
    {
        
        if([self NSStringIsValidEmail:[emailTextField text]])
        {
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"傳送中" message:@"傳送資料中" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [progressDialog show];
            
            request = [ASIFormDataRequest requestWithURL:
                       [NSURL URLWithString:@"http://www.invivointeractive.com/crms/index.php/crms_enquiry/create/"]];
            
            [request setPostValue:[nameTextField text] forKey:@"u_name"];
            [request setPostValue:[emailTextField text] forKey:@"u_email"];
            [request setPostValue:[detailTextView text] forKey:@"u_detail"];
            NSNumber *opinionType = [NSNumber numberWithInt:opinionSegmentedControl.selectedSegmentIndex];
            [request setPostValue:[opinionType stringValue] forKey:@"u_type"];
            [request setPostValue:@"SpokenNews" forKey:@"u_app"];
            [request setPostValue:@"1.0" forKey:@"u_version"];
            
            [request setCompletionBlock:^(void) {
                resultTitle = @"傳送完成";
                resultMsg = @"感謝你提供的寶貴資料！";
                [progressDialog dismissWithClickedButtonIndex:-1 animated:YES];
            }];
            
            [request setFailedBlock:^(void){
                resultTitle = @"傳送失敗";
                resultMsg = @"請檢查網絡再試";
                [progressDialog dismissWithClickedButtonIndex:-1 animated:YES];
            }];
            
            //
            
            [detailTextView resignFirstResponder];
            [nameTextField resignFirstResponder];
            [emailTextField resignFirstResponder];
            
            
            [progressDialog show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"電郵格式錯誤" message:@"請重新輸入再試" delegate:self cancelButtonTitle:@"了解" otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"尚有未填入資料" message:@"請重新輸入再試" delegate:self cancelButtonTitle:@"了解" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView{
    if(alertView.tag == 999)
    {
        [progressView setCenter:CGPointMake(progressDialog.frame.size.width/2 , progressDialog.frame.size.height/2)];
        if(isDebug)
            NSLog(@"center: %.1f, %.1f", progressView.center.x, progressView.center.y);
        [request startAsynchronous];
    }
}

NSString *resultMsg;
NSString *resultTitle;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 999)
    {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:resultTitle message:resultMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
}

-(BOOL) NSStringIsNotEmpty:(NSString*)checkString
{
    if([[checkString stringByReplacingOccurrencesOfString:@" " withString:@""]isEqualToString:@""])
    {
        return NO;
    }
    return YES;
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
