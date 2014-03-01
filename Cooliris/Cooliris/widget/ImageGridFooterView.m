//
//  FooterView.m
//  TestCollectionView
//
//  Created by user on 13-6-26.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "ImageGridFooterView.h"

@interface ImageGridFooterView ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation ImageGridFooterView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    
    return self;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//     //_messageLabel.hidden = YES;
//}

- (void)startLoading
{
    [_indicator startAnimating];
    _messageLabel.hidden = YES;
}

- (void)completedLoading
{
    [self completedLoading:nil];
}

- (void)completedLoading:(NSString *)withShowingMessage
{
    [_indicator stopAnimating];
    
    if (withShowingMessage) {
        _messageLabel.hidden = NO;
        _messageLabel.text = withShowingMessage;
    }
}

@end
