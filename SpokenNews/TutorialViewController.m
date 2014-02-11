//
//  TutorialViewController.m
//  SpokenNews
//
//  Created by Kwok Yu Ho on 14/2/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@end

@implementation TutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    contentDictArr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"TutorialData" ofType:@"plist"]];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if(!isLoad)
    {
        [super viewDidAppear:animated];
        [pageControl setNumberOfPages:[contentDictArr count]];
        [scrollView setContentSize:CGSizeMake(scrollView.bounds.size.width*[contentDictArr count],
                                              scrollView.bounds.size.height)];
        
        CGFloat w = scrollView.bounds.size.width;
        CGFloat h = scrollView.bounds.size.height;
        
        for(int i = 0; i<[contentDictArr count]; i++)
        {
            NSDictionary *contentDict = [contentDictArr objectAtIndex:i];
            NSString *path = [contentDict objectForKey:@"image"];
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake( w*i,
                                                                                0, w, h)];
            [imgView setImage:[UIImage imageNamed:path]];
//            [imgView setContentMode:UIViewContentModeTop];
            [imgView setContentMode:UIViewContentModeScaleAspectFit];
            [scrollView addSubview:imgView];
            
            if(i==0)
            {
                [descriptionTextView setText:[contentDict objectForKey:@"description"]];
            }
        }
        isLoad = YES;
    }
    [scrollView setContentOffset:CGPointMake(0,0)];
    
    [UIView animateWithDuration:0.3f animations:^(void){
        [scrollView setAlpha:1.0f];
    }];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)_scrollView{
    CGPoint contentOffset = _scrollView.contentOffset;
    [pageControl setCurrentPage:(contentOffset.x/(_scrollView.bounds.size.width))];
    
    NSDictionary *contentDict = [contentDictArr objectAtIndex:pageControl.currentPage];
    [descriptionTextView setText:[contentDict objectForKey:@"description"]];
    
    if([contentDictArr count] == (pageControl.currentPage+1))
    {
        [closeBtn setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)closeTutorial:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}



@end
