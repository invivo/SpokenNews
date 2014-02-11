//
//  TutorialViewController.h
//  SpokenNews
//
//  Created by Kwok Yu Ho on 14/2/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController<UIScrollViewDelegate>
{
    NSArray *contentDictArr;
    IBOutlet UIPageControl* pageControl;
    IBOutlet UIScrollView* scrollView;
    IBOutlet UITextView *descriptionTextView;
    IBOutlet UIButton *closeBtn;
    
    BOOL isLoad;
}
-(IBAction)closeTutorial:(id)sender;
@end
