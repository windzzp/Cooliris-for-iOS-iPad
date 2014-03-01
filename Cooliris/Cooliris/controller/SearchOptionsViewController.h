//
//  SearchOptionsViewController.h
//  Cooliris
//
//  Created by user on 13-6-18.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchOptionsDelegate <NSObject>

@optional
- (void)searchTypeChanged:(NSUInteger)type;
- (void)searchNetResolutionChanged:(NSInteger)index resolution:(NSString *)resolution;
- (void)searchNetResolutionChanged:(NSInteger)width height:(NSInteger)height;
- (void)searchLocalTagChanged:(NSString *)tag;

@end

@interface SearchOptionsViewController : UIViewController <SearchOptionsDelegate>

@property (strong, nonatomic) id<SearchOptionsDelegate> delegate;

@end
