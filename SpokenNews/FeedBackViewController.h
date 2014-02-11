//
//  FeedBackViewController.h
//  SpokenNews
//
//  Created by Kwok Yu Ho on 14/2/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface FeedBackViewController : UITableViewController<UIAlertViewDelegate>
{
    IBOutlet UITextField *nameTextField;
    IBOutlet UITextField *emailTextField;
    IBOutlet UITextView *detailTextView;
    IBOutlet UISegmentedControl *opinionSegmentedControl;
    
    ASIFormDataRequest *request;
    UIAlertView *progressDialog;
    
    UIActivityIndicatorView *progressView;
}

-(IBAction)sendFeedBack:(id)sender;
@end
