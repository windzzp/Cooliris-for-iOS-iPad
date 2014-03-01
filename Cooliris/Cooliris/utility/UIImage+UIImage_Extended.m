//
//  UIImage+UIImage_Extended.m
//  Cooliris
//
//  Created by user on 13-5-22.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "UIImage+UIImage_Extended.h"

#define LOG_TAG @"UIImage"
#define DEGREES_TO_RADIANS(degrees) (degrees * M_PI / 180.0)
#define RADIANS_TO_DEGREES(radians) (radians * 180.0 / M_PI)

@implementation UIImage (UIImage_Extended)

- (UIImage *)imageAtRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
}

- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage    = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width    = imageSize.width;
    CGFloat height   = imageSize.height;
    
    CGFloat targetWidth  = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor  = 0.0;
    CGFloat scaledWidth  = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor  = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) {
        // could not scale image
    }
    
    return newImage ;
}

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage    = nil;
    
    CGSize imageSize = sourceImage.size;
    CGFloat width    = imageSize.width;
    CGFloat height   = imageSize.height;
    
    CGFloat targetWidth  = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaleFactor  = 0.0;
    CGFloat scaledWidth  = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor < heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor < heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor > heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) {
        //could not scale image
    }
    
    return newImage ;
}

- (UIImage *)imageByScalingToSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;
    
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    // this is actually the interesting part:
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(newImage == nil) {
        // could not scale image
    }
    
    return newImage ;
}

- (UIImage *)imageRotatedByRadians:(CGFloat)radians
{
    return [self imageRotatedByDegrees:RADIANS_TO_DEGREES(radians)];
}

- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees
{
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      self.size.width,
                                                                      self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    CGContextRotateCTM(bitmap, DEGREES_TO_RADIANS(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap,
                       CGRectMake(-self.size.width / 2,
                                  -self.size.height / 2,
                                  self.size.width,
                                  self.size.height),
                       [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage *)fixOrientation:(UIImageOrientation)imageOrientation
{
    CGFloat angle;
    switch (imageOrientation) {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            angle = 0;
            break;
            
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            angle = M_PI;
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            angle = -M_PI_2;
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            angle = M_PI_2;
            break;
    }
    
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      self.size.width,
                                                                      self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(angle);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    CGContextRotateCTM(bitmap, angle);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap,
                       CGRectMake(-self.size.width / 2,
                                  -self.size.height / 2,
                                  self.size.width,
                                  self.size.height),
                       [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImageOrientation)rotateImageOrientation:(UIImageOrientation)currentOrientation
                                 isClockWise:(BOOL)isClockWise
{
    UIImageOrientation imageOrientation;
    switch (currentOrientation) {
        case UIImageOrientationUp:
            imageOrientation = isClockWise ? UIImageOrientationRight : UIImageOrientationLeft;
            break;
            
        case UIImageOrientationUpMirrored:
            imageOrientation = isClockWise ? UIImageOrientationRightMirrored : UIImageOrientationLeftMirrored;
            break;
            
        case UIImageOrientationDown:
            imageOrientation = isClockWise ? UIImageOrientationLeft : UIImageOrientationRight;
            break;
            
        case UIImageOrientationDownMirrored:
            imageOrientation = isClockWise ? UIImageOrientationLeftMirrored : UIImageOrientationRightMirrored;
            break;
            
        case UIImageOrientationLeft:
            imageOrientation = isClockWise ? UIImageOrientationUp : UIImageOrientationDown;
            break;
            
        case UIImageOrientationLeftMirrored:
            imageOrientation = isClockWise ? UIImageOrientationUpMirrored : UIImageOrientationDownMirrored;
            break;
            
        case UIImageOrientationRight:
            imageOrientation = isClockWise ? UIImageOrientationDown : UIImageOrientationUp;
            break;
            
        case UIImageOrientationRightMirrored:
            imageOrientation = isClockWise ? UIImageOrientationDownMirrored : UIImageOrientationUpMirrored;
            break;
    }
    
    return imageOrientation;
}

- (UIImage *)centerCropImage:(CGFloat)withCropWidth
{
    CGFloat finalCropWidth = withCropWidth;
    
    // If the image's size less than the croped width, we should use the
    // image's minimal edge to create a new image.
    if (self.size.width < withCropWidth || self.size.height < withCropWidth) {
        finalCropWidth = MIN(self.size.width, self.size.height);
    }
    
    CGRect cropRect = {
        floorf((self.size.width - finalCropWidth) / 2),
        floorf((self.size.height - finalCropWidth) / 2),
        finalCropWidth,
        finalCropWidth};
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], cropRect);
    UIImage *subImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return subImage;
}

@end
