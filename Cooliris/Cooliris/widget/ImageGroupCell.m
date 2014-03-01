//
//  ImageGroupCell.m
//  Cooliris
//
//  Created by user on 13-6-4.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ImageGroupCell.h"
#import "UIImageView+WebCache.h"
#import "ImageGroup.h"

@interface ImageGroupCell ()

@property (strong, nonatomic) UIImageView *selectedImageView;

@property (strong, nonatomic) UIColor* normalColor;
@property (strong, nonatomic) UIColor* selectedColor;
@property (nonatomic) CGFloat normalColorWidth;
@property (nonatomic) CGFloat selectedColorWidth;

- (void)initInternal;
- (void)setBorderColorInternal:(UIColor *)color withWidth:(CGFloat)width;

@end

@implementation ImageGroupCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initInternal];
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

#pragma mark - Public method and public property method

- (void)setImageData:(ImageGroup *)imageData
{
    [self setImageData:imageData useThumbnail:NO];
}

- (void)setBorderColor:(UIColor *)color withWidth:(CGFloat)width inState:(BOOL)selected
{
    if (selected) {
        self.selectedColor = color;
        self.selectedColorWidth = width;
    } else {
        self.normalColor = color;
        self.normalColorWidth = width;
    }
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        _image = image;
    }
    
    self.imageView.image = self.image;
}

#pragma mark - Override default properties method

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        [self setBorderColorInternal:self.selectedColor withWidth:self.selectedColorWidth];
    } else {
        [self setBorderColorInternal:self.normalColor withWidth:self.normalColorWidth];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    //  This avoids the animation runs every time the cell is reused
    if (self.isHighlighted != highlighted){
        _imageView.alpha = 0.0;
        [UIView animateWithDuration:0.3 animations:^{
            _imageView.alpha = 1.0;
        }];
    }
    
    [super setHighlighted:highlighted];
}

#pragma mark - Implemented private methods

- (void)initInternal
{
    [self setBorderColor:[UIColor blackColor] withWidth:1 inState:NO];
    [self setBorderColor:[UIColor blackColor] withWidth:1 inState:YES];
    //self.selected = NO;
    
    float randomWhite = (arc4random() % 40 + 10) / 255.0;
    self.backgroundColor = [UIColor colorWithWhite:randomWhite alpha:1];
}

- (void)setFrameSingleLine
{
    self.detailView.hidden = NO;
    self.descriptionLabel.hidden = YES;
    self.detailDescription.numberOfLines = 0;
    self.imageView.frame = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    self.detailView.frame = CGRectMake(self.bounds.size.height, 0, self.bounds.size.width - self.bounds.size.height, self.bounds.size.height);
    self.detailTitle.frame = CGRectMake(10, 15, self.detailView.frame.size.width - 20, 18);
    self.detailDescription.frame = CGRectMake(10, 35, self.detailView.frame.size.width - 20, 50);
    
    float randomWhite = (arc4random() % 40 + 10) / 255.0;
    self.detailView.backgroundColor = [UIColor colorWithWhite:randomWhite alpha:1];
    
    if (INTERFACE_IS_PHONE) {
        [self.detailTitle setFont:[UIFont boldSystemFontOfSize:11]];
        [self.detailDescription setFont:[UIFont systemFontOfSize:9]];
    }
}

- (void)setFrameDetail
{
    self.detailView.hidden = NO;
    self.descriptionLabel.hidden = YES;
    self.detailDescription.numberOfLines = 2;
    self.imageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 80);
    self.detailView.frame = CGRectMake(0, self.bounds.size.height - 80, self.bounds.size.width, 80);
    self.detailTitle.frame = CGRectMake(8, 8, self.bounds.size.width - 16, 18);
    self.detailDescription.frame = CGRectMake(8, 25, self.bounds.size.width - 16, 50);
    
    float randomWhite = (arc4random() % 40 + 10) / 255.0;
    self.detailView.backgroundColor = [UIColor colorWithWhite:randomWhite alpha:1];
    
    if (INTERFACE_IS_PHONE) {
        [self.detailTitle setFont:[UIFont boldSystemFontOfSize:11]];
        [self.detailDescription setFont:[UIFont systemFontOfSize:9]];
    }
}

- (void)setFrameNoDetail
{
    self.detailView.hidden = YES;
    self.descriptionLabel.hidden = NO;
    self.imageView.frame = self.bounds;
    self.descriptionLabel.frame = CGRectMake(0, self.bounds.size.height - 25, self.bounds.size.width, 25);
    
    if (INTERFACE_IS_PHONE) {
        [self.descriptionLabel setFont:[UIFont systemFontOfSize:10]];
    }
}

- (void)setBorderColorInternal:(UIColor *)color withWidth:(CGFloat)width
{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    self.clipsToBounds = YES;
    
    // We can also use the following code to set border
    //self.imageView.layer.borderColor = [color CGColor];
    //self.imageView.layer.borderWidth = width;
}

- (void)setImageData:(ImageGroup *)imageData useThumbnail:(BOOL)useThumbnail
{
    if (_imageData != imageData) {
        _imageData = imageData;
        
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.fadeIn = YES;
        [_imageView setImageWithURL:[NSURL URLWithString:useThumbnail ? _imageData.coverUrl : _imageData.coverUrl]
                   placeholderImage:nil//[UIImage imageNamed:@"placeholder"]
                            options:0];
        
        _descriptionLabel.text = _imageData.title;
        _detailTitle.text = _imageData.title;
        _detailDescription.text = _imageData.description;
        
//        CGSize textSize = [_detailDescription.text
//                           sizeWithFont:_detailDescription.font
//                           constrainedToSize:CGSizeMake(_detailDescription.frame.size.width, 100)
//                           lineBreakMode:NSLineBreakByWordWrapping];
//        CGRect tmpFrame = self.detailDescription.frame;
//        tmpFrame.size.height = textSize.height;
//        _detailDescription.frame = tmpFrame;
        
        self.selected = NO;
        //self.imageView.alpha = 1.0;
    }
}


@end
