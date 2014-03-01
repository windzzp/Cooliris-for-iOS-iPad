//
//  SearchPopoverBackgroundView.m
//  Cooliris
//
//  Created by user on 13-6-19.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "SearchPopoverBackgroundView.h"

#define CONTENT_INSET 10.0
#define CAP_INSET     25.0
#define ARROW_BASE    20.0
#define ARROW_HEIGHT  20.0

@implementation SearchPopoverBackgroundView

#pragma mark - Init Method

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *background = [UIImage imageNamed:@"Icon_popover_background"];
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(CAP_INSET, CAP_INSET, CAP_INSET, CAP_INSET);
        
        _borderImageView = [[UIImageView alloc] initWithImage:[background resizableImageWithCapInsets:edgeInsets]];
        UIImage *arrow = [UIImage imageNamed:@"Icon_popover_Arrow"];
        _arrowView = [[UIImageView alloc] initWithImage:arrow];
        
        [self addSubview:_borderImageView];
        [self addSubview:_arrowView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Get/Set Method

- (CGFloat)arrowOffset
{
    return _arrowOffset;
}

- (void)setArrowOffset:(CGFloat)arrowOffset
{
    _arrowOffset = arrowOffset;
}

- (UIPopoverArrowDirection)arrowDirection
{
    return _arrowDirection;
}

- (void)setArrowDirection:(UIPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
}

+ (UIEdgeInsets)contentViewInsets
{
    return UIEdgeInsetsMake(CONTENT_INSET, CONTENT_INSET, CONTENT_INSET, CONTENT_INSET);
}

+ (CGFloat)arrowHeight
{
    return ARROW_HEIGHT;
}

+(CGFloat)arrowBase
{
    return ARROW_BASE;
}

#pragma mark - LayoutSubViews

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat _height = self.frame.size.height;
    CGFloat _width  = self.frame.size.width;
    CGFloat _left   = 0.0;
    CGFloat _top    = 0.0;
    CGFloat _coordinate = 0.0;
    CGAffineTransform _rotation = CGAffineTransformIdentity;
    
    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionUp:
            _top    += ARROW_HEIGHT;
            _height -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE / 2);
            _arrowView.frame = CGRectMake(_coordinate, 0, ARROW_BASE, ARROW_HEIGHT);
            break;
            
        case UIPopoverArrowDirectionDown:
            _height    -= ARROW_HEIGHT;
            _coordinate = ((self.frame.size.width / 2) + self.arrowOffset) - (ARROW_BASE / 2);
            _arrowView.frame = CGRectMake(_coordinate, _height, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation(M_PI);
            break;
            
        case UIPopoverArrowDirectionLeft:
            _left  += ARROW_BASE;
            _width -= ARROW_BASE;
            _coordinate = ((self.frame.size.height / 2) +self.arrowOffset) - (ARROW_HEIGHT / 2);
            _arrowView.frame = CGRectMake(0, _coordinate, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation(-M_PI_2);
            break;
            
        case UIPopoverArrowDirectionRight:
            _width     -= ARROW_BASE;
            _coordinate = ((self.frame.size.height / 2) + self.arrowOffset) - (ARROW_HEIGHT / 2);
            _arrowView.frame = CGRectMake(_width, _coordinate, ARROW_BASE, ARROW_HEIGHT);
            _rotation = CGAffineTransformMakeRotation(M_PI_2);
            break;
            
        default:
            break;
    }
    
    _borderImageView.frame = CGRectMake(_left, _top, _width, _height);
    [_arrowView setTransform:_rotation];
}

@end
