//
//  GoogleAnalytics.m
//  Cooliris
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import "GoogleAnalytics.h"

/******* Set MediaGuide tracking ID here *******/
#ifdef DEBUG
static NSString *const kTrackingId = @"UA-37665042-5";
#else
static NSString *const kTrackingId = @"UA-35377825-9";
#endif

// Default Google Analytics
static GoogleAnalytics *s_defaultGoogleAnalytics = nil;

@implementation GoogleAnalytics

@synthesize currentScreen;
@synthesize GAITracker;

+ (GoogleAnalytics *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (nil == s_defaultGoogleAnalytics) {
            s_defaultGoogleAnalytics = [[GoogleAnalytics alloc] init];
        }
    });
    
    return s_defaultGoogleAnalytics;
}

- (void)initialize
{
#ifdef DEBUG
    [GAI sharedInstance].debug = YES;
#else
    [GAI sharedInstance].debug = NO;
#endif
    
    // Initialize Google Analytics with a 120-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].dispatchInterval = 120;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    GAITracker = [[GAI sharedInstance] trackerWithTrackingId:kTrackingId];
}

- (BOOL)sendScreenView:(NSString *)screenName withOrientation:(BOOL) isLandscape
{
    currentScreen = screenName;
    
    if (![GAI sharedInstance].optOut) {
        if (screenName != nil) {
            screenName = [NSString stringWithFormat:@"%@?orientation=%@",
                          currentScreen,
                          isLandscape ? @"landscape" : @"portrait"];
            return [GAITracker sendView:screenName];
        }
    }
    return NO;
}

- (BOOL)sendEventWithCategory:(NSString *)category
                   withAction:(NSString *)action
                    withLabel:(NSString *)label
                    withValue:(NSNumber *)value
{
    if (![GAI sharedInstance].optOut) {
        if (category != nil && action != nil && label != nil){
            return [GAITracker sendEventWithCategory:category
                                          withAction:action
                                           withLabel:label
                                           withValue:value];
        }
    }
    return NO;
}

- (BOOL)sendException:(BOOL)isFatal withDescription:(NSString *)description
{
    if (![GAI sharedInstance].optOut) {
        return [GAITracker sendException:isFatal withDescription:description];
    }
    return NO;
}

- (BOOL)sendException:(BOOL)isFatal withNSError:(NSError *)error
{
    if (![GAI sharedInstance].optOut) {
        return [GAITracker sendException:isFatal withNSError:error];
    }
    return NO;
}

- (BOOL)sendException:(BOOL)isFatal withNSException:(NSException *)exception
{
    if (![GAI sharedInstance].optOut) {
        return [GAITracker sendException:isFatal withNSException:exception];
    }
    return NO;
}

- (void)setSendUncaughtExceptionsEnabled:(BOOL)isEnable
{
    [GAI sharedInstance].trackUncaughtExceptions = isEnable;
}

- (void)setCampaignUrl:(NSString *)campaignUrl
{
    [GAITracker setCampaignUrl:campaignUrl];
}

- (void)setReferrerUrl:(NSString *)referrerUrl
{
    [GAITracker setReferrerUrl:referrerUrl];
}

- (void)setSendToGoolgleEnabled:(BOOL)isEnable
{
    [GAI sharedInstance].optOut = !isEnable;
}

- (void)setSendAnonymousEnabled:(BOOL)isEnable
{
    [GAITracker setAnonymize:isEnable];
}

@end
