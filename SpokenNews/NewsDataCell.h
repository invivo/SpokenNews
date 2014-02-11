//
//  NewsDataCell.h
//  SpokenNews
//
//  Created by Kwok Yu Ho on 5/2/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsDataCell : UITableViewCell
{
    IBOutlet UITextView* textView;
    IBOutlet UIView* bgView;
}
@property (nonatomic, strong) UITextView* textView;
@property (nonatomic, strong) UIView* bgView;
@end
