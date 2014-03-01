//
//  UIImage+UIImage_Extended.h
//  Cooliris
//
//  This file is the extension of the UIImage.
//
//  Created by user on 13-5-22.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImage_Extended)

/**
 * Get the image at a rect.
 *
 * @param rect.
 */
- (UIImage *)imageAtRect:(CGRect)rect;

/**
 * Scale the image proportionally.
 *
 * @param targetSize. The target size to scale.
 */
- (UIImage *)imageByScalingProportionallyToMinimumSize:(CGSize)targetSize;

/**
 * Scale the image proportionally.
 *
 * @param targetSize. The target size to scale.
 */
- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;

/**
 * Scale the image.
 *
 * @param targetSize. The target size to scale.
 */
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

/**
 * Rotate the image by radians.
 *
 * @param radians. The radians to rotate.
 */
- (UIImage *)imageRotatedByRadians:(CGFloat)radians;

/**
 * Rotate the image by degrees.
 *
 * @param degrees. The degrees to rotate.
 */
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;

/**
 * Fix the orientation.
 *
 * @param imageOrientation. The image orientation to fixed.
 */
- (UIImage *)fixOrientation:(UIImageOrientation)imageOrientation;

/**
 * Get the orientation after rotate from current orientation.
 *
 * @param imageOrientation. The current image orientation.
 * @param isClockWise. Whether image is rotated ClockWise.
 */
- (UIImageOrientation)rotateImageOrientation:(UIImageOrientation)currentOrientation
                                 isClockWise:(BOOL)isClockWise;

/**
 * Center crop the image with specified cropped width. It'll return a new square image which 
 * the size is |cropWidth|*|cropWidth|. Note that if the |cropWidth| > |image min edge|, 
 * the image size is |image min edge|*|image min edge|.
 *
 * @param cropWidth The specified crop width.
 *
 * @return The new image which has been cropped.
 */

- (UIImage *)centerCropImage:(CGFloat)withCropWidth;

@end
