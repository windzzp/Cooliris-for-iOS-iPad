//
//  CPSectionView.m
//  ExpansionTableView
//
//  Created by user on 13-6-18.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "CPHeaderView.h"

#define kNormalColor    [UIColor grayColor]
#define kHighlightColor [UIColor colorWithRed:66.0/255 green:133.0/255 blue:244.0/255 alpha:1.0]

@interface CPHeaderView ()

//@property (strong, nonatomic) IBOutlet UIImageView *backgroundView;
//@property (strong, nonatomic) IBOutlet UILabel *label;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIButton *backgroundButton;

@end

@implementation CPHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        // Initialization code
//        _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
//        _label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, self.bounds.size.width - 60, self.bounds.size.height - 2 * 2)];
//        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 60 - 10, 5, 40, self.bounds.size.height - 5 * 2)];
//        
//        _backgroundView.image = [UIImage imageNamed:@"Icon_cpcellview_background"];
//        _label.text = @"TEXT";
//        _label.backgroundColor = [UIColor clearColor];
//        _label.textColor = [UIColor grayColor];
//        
//        _imageView.image = [UIImage imageNamed:@"Icon_gear"];
//        _imageView.contentMode = UIViewContentModeScaleAspectFit;
//        
//        [self addSubview:_backgroundView];
//        [self addSubview:_label];
//        [self addSubview:_imageView];
        
        //UIImage *backgroundImage = [UIImage imageNamed:@"Icon_cpcellview_background"];
        UIImage *backgroundImage = [UIImage imageNamed:@"Icon_cp_header_background"];
        _backgroundButton = [[UIButton alloc] initWithFrame:self.bounds];
        //[_backgroundButton setSelected:YES];
        
        [_backgroundButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0]];
        
        [_backgroundButton setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [_backgroundButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [_backgroundButton setTitleColor:kNormalColor forState:UIControlStateNormal];
        [_backgroundButton setTitleColor:kHighlightColor forState:UIControlStateHighlighted];
        
        [_backgroundButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
        [_backgroundButton setBackgroundImage:backgroundImage forState:UIControlStateHighlighted];
        [_backgroundButton addTarget:self action:@selector(didTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_backgroundButton];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    //_backgroundButton.titleLabel.text = title;
    [_backgroundButton setTitle:title forState:UIControlStateNormal];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    UIColor *newColor = _highlighted ? kHighlightColor : kNormalColor;
    [_backgroundButton setTitleColor:newColor forState:UIControlStateNormal];
}

- (void)didTapped
{
    if (_delegate && [_delegate respondsToSelector:@selector(selectedHeaderWith:)]) {
        [_delegate selectedHeaderWith:self];
        
        [_backgroundButton setTitleColor:kHighlightColor forState:UIControlStateNormal];
        //UIColor *newColor = _isActivied ? kHighlightColor : kNormalColor;
        //[_backgroundButton setTitleColor:newColor forState:UIControlStateNormal];
    }
}

@end
