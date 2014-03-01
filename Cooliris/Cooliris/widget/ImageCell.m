//
//  ImageCell.m
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ImageCell.h"
#import "UIImageView+WebCache.h"
#import "Image.h"

@interface ImageCell ()

@property (strong, nonatomic) UIImageView *selectedImageView;

@property (strong, nonatomic) UIColor* normalColor;
@property (strong, nonatomic) UIColor* selectedColor;
@property (nonatomic) CGFloat normalColorWidth;
@property (nonatomic) CGFloat selectedColorWidth;

- (void)initInternal;
- (void)setBorderColorInternal:(UIColor *)color withWidth:(CGFloat)width;

@end

@implementation ImageCell

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

- (void)setImageData:(Image *)imageData
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

//- (void)setIsMultiSelected:(BOOL)isMultiSelected
//{
//    _isMultiSelected = isMultiSelected;
////    if (isMultiSelected) {
////        if (nil == _selectedImageView) {
////            CGRect frame = {
////                _imageView.bounds.size.width - 50,
////                _imageView.bounds.size.height - 50, 
////                32, 32
////            };
////            _selectedImageView = [[UIImageView alloc] initWithFrame:frame];
////            _selectedImageView.image = [UIImage imageNamed:@"selected"];
////            //[_selectedImageView addConstraint:[NSLayoutConstraint]]
////            //[self addSubview:_selectedImageView];
////        }
////        self.selectedImageView.hidden = NO;
////        
////    } else {
////        self.selectedImageView.hidden = YES;
////    }
//    
//    if (isMultiSelected) {
//        self.imageView.alpha = 0.5;
//    } else {
//        self.imageView.alpha = 1.0;
//    }
//}

//- (void)setIsMultiSelected:(BOOL)isMultiSelected
//{
//    _isMultiSelected = isMultiSelected;
//    if (isMultiSelected) {
//        self.selectedView.hidden = NO;
//        
//    } else {
//        self.selectedView.hidden = YES;
//    }
//}

#pragma mark - Implemented private methods

- (void)initInternal
{
    [self setBorderColor:[UIColor blackColor] withWidth:1 inState:NO];
    [self setBorderColor:[UIColor blackColor] withWidth:1 inState:YES];
    //self.selected = NO;
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

- (void)setImageData:(Image *)imageData useThumbnail:(BOOL)useThumbnail
{
    if (_imageData != imageData) {
        _imageData = imageData;
        
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.fadeIn = YES;
        [_imageView setImageWithURL:[NSURL URLWithString:useThumbnail ? _imageData.thumbUrl : _imageData.url]
                   placeholderImage:[UIImage imageNamed:@"placeholder"]
                            options:0];
        
        _descriptionLabel.text = @"生命巨像CG主题插画欣赏"; //_imageData.description;
        
        //self.selected = NO;
        //self.imageView.alpha = 1.0;
    }
}

@end
