/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import <QuartzCore/QuartzCore.h>

#define kFadeInTime 0.25
#define kFadeInKey @"kFadeInKey"

static char operationKey;

@implementation UIImageView (WebCache)

@dynamic fadeIn;

- (void)setFadeIn:(BOOL)fadeIn
{
    objc_setAssociatedObject(self, kFadeInKey, [NSNumber numberWithBool:fadeIn], OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)fadeIn
{
    return [(NSNumber *)objc_getAssociatedObject(self, kFadeInKey) boolValue];
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock;
{
    [self cancelCurrentImageLoad];

    self.image = placeholder;
    
    if (url)
    {
        __weak UIImageView *wself = self;
        
        /* [Add] [Author: liulin] at 2013-05-27 18:06 ---> */
        // Before do background process, we need to find the cache has existed
        // in memory cache, if existed, directly set the image into UIImageView.
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        UIImage *memoryImage = [manager.imageCache imageFromMemoryCacheForKey:url.absoluteString];
        if (memoryImage) {
            __strong UIImageView *sself = wself;
            if (!sself) return;
            sself.image = memoryImage;
        } else {
        /* <--- [Add] */
            id<SDWebImageOperation> operation =
            [manager downloadWithURL:url
                             options:options
                            progress:progressBlock
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
             {
                 __strong UIImageView *sself = wself;
                 if (!sself) return;
                 if (image)
                 {
                     // Add fade in animation
                     if (self.fadeIn) {
                         [self displayWithAnimation];
                     }
                     
                     sself.image = image;
                     //[sself setNeedsLayout];
                 }
                 
                 if (completedBlock && finished)
                 {
                     completedBlock(image, error, cacheType);
                 }
             }];
            objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

- (void)cancelCurrentImageLoad
{
    // Cancel in progress downloader from queue
    id<SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation)
    {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)displayWithAnimation
{
    CATransition *transition = [CATransition animation];
    transition.duration = kFadeInTime;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = self;
    [self.layer addAnimation:transition forKey:nil];
    
//    //CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"bounds"];
//    //scaleAnim.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.bounds.size.width * 1.1, self.bounds.size.height * 1.1)];
//    //scaleAnim.toValue = [NSValue valueWithCGRect:self.bounds];
//    //[self.layer addAnimation:scaleAnimation forKey:@"bounds"];
//    
//    CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
//    scaleAnim.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)];
//    scaleAnim.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
//    
//    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
//    animGroup.animations = @[transition, scaleAnim];
//    animGroup.duration = kFadeInTime;
//    [self.layer addAnimation:animGroup forKey:nil];
//    
//    //self.bounds = CGRectMake(0, 0, self.bounds.size.width * 1.1, self.bounds.size.height * 1.1);
//    //[UIView animateWithDuration:kFadeInTime animations:^{
//    //    self.bounds = CGRectMake(0, 0, self.bounds.size.width / 1.1, self.bounds.size.height / 1.1);
//    //}];
}

@end
