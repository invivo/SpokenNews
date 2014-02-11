//
//  NewsDataCell.m
//  SpokenNews
//
//  Created by Kwok Yu Ho on 5/2/13.
//  Copyright (c) 2013 invivo interactive. All rights reserved.
//

#import "NewsDataCell.h"

@implementation NewsDataCell
@synthesize textView, bgView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
