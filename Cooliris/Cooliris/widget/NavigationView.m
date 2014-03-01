//
//  NavigationView.m
//  ExpansionTableView
//
//  Created by user on 13-6-19.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "NavigationView.h"

@implementation NavigationView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.cellMode == NavigationMode) {
        self.imageView.frame = CGRectInset(self.imageView.frame, 5, 5);
        self.imageView.frame = CGRectOffset(self.imageView.frame, 5, 0);
    } else if (self.cellMode == CustomCellMode) {
        self.imageView.frame = CGRectInset(self.imageView.frame, 5, 8);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
