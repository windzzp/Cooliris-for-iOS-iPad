//
//  GoogleAnalytics.h
//  Cooliris
//
//  This file is used to send Google Analytics and set the parameters when sending.
//
//  Created by user on 13-5-21.
//  Copyright (c) 2013年 user. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAI.h"

@interface GoogleAnalytics : NSObject

@property (nonatomic, strong) NSString *currentScreen;
@property (nonatomic, strong) id<GAITracker> GAITracker;

+ (GoogleAnalytics *)sharedInstance;

- (void)initialize;

/**
 * Track that the specified view or screen was displayed. 
 * Set the appScreen property and generates tracking information to be sent to Google Analytics.
 *
 * @param screenName. The screen The name of the screen. Must not be `nil`.
 * @param isLandscape. The orientation of the screen.
 * @return `YES` if the tracking information was queued for dispatch, 
 *         or `NO` if there was an error (e.g. the tracker was closed).
 */
- (BOOL)sendScreenView:(NSString *)screenName withOrientation:(BOOL) isLandscape;


/**
 * Track an event.
 * If [GAI optOut] is true, this will not generate any tracking information.
 *
 * @param category. The event category, or `nil` if none. 
 * @param action. The event action, or `nil` if none.
 * @param label. The event label, or `nil` if none.
 * @param value. The event value, to be interpreted as a 64-bit signed integer, or `nil` if none.
 * @return `YES` if the tracking information was queued for dispatch, 
 *         or `NO` if there was an error (e.g. the tracker was closed).
 */
- (BOOL)sendEventWithCategory:(NSString *)category
                   withAction:(NSString *)action
                    withLabel:(NSString *)label
                    withValue:(NSNumber *)value;


/**
 * Track an exception.
 * If [GAI optOut] is true, this will not generate any tracking information.
 *
 * @param isFatal. A boolean indicating whether the exception is fatal.
 * @param description. A description of the exception (up to 100 characters). Accepts nil. 
 * @return `YES` if the tracking information was queued for dispatch, 
 *         or `NO` if there was an error (e.g. the tracker was closed).
 */
- (BOOL)sendException:(BOOL)isFatal withDescription:(NSString *)description;


/**
 * Tracking an NSError that passes the domain, code, and description to trackException:withDescription:.
 * If [GAI optOut] is true, this will not generate any tracking information.
 *
 * @param isFatal. A boolean indicating whether the exception is fatal.
 * @param error. The NSError error object.
 * @return `YES` if the tracking information was queued for dispatch, 
 *         or `NO` if there was an error (e.g. the tracker was closed).
 */
- (BOOL)sendException:(BOOL)isFatal withNSError:(NSError *)error;

/**
 * Tracking an NSException that passes the exception name to trackException:withDescription:.
 * If [GAI optOut] is true, this will not generate any tracking information.
 *
 * @param isFatal A boolean indicating whether the exception is fatal.
 * @param exception The NSException exception object.
 * @return `YES` if the tracking information was queued for dispatch, 
 *         or `NO` if there was an error (e.g. the tracker was closed).
 */
- (BOOL)sendException:(BOOL)isFatal withNSException:(NSException *)exception;

/**
 * If enabled, the SDK will record the currently registered uncaught exception handler, 
 * and track the exception on the tracker and attempt to dispatch outstanding tracking information for 5s. 
 * When not enabled, the previously registered uncaught exception handler will be restored.
 *
 * @param isEnable.
 */
- (void)setSendUncaughtExceptionsEnabled:(BOOL)isEnable;


/**
 * Set the campaign URL for this tracker. 
 * This is not directly propagated to Google Analytics, but if there are campaign parameter(s), 
 * either manually or auto-tagged, present in this URL, the SDK will include those parameters 
 * in the next dispatch of tracking information. Google Analytics treats tracking
 * information with differing campaign information as part of separate sessions.
 * For more information on auto-tagging, see
 * http://support.google.com/googleanalytics/bin/answer.py?hl=en&answer=55590
 * For more information on manual tagging, see
 * http://support.google.com/googleanalytics/bin/answer.py?hl=en&answer=55518
 *
 * @param campaignUrl. A valid Campaign Parameter string.
 */
- (void)setCampaignUrl:(NSString *)campaignUrl;

/**
 * Set the referrer URL for this tracker. 
 * Changing this value causes it to be sent with the next dispatch of tracking information.
 *
 * @param referrer. A string like "google.com" or "myOtherApp", rather than a string of campaign parameters.
 */
- (void)setReferrerUrl:(NSString *)referrerUrl;

/**
 * Set whether allow to send google analytics;
 * When enabled, tracking calls will become ops, and tracking information will be gathered.
 * 
 * @param BOOL isEnable.
 */
- (void)setSendToGoolgleEnabled:(BOOL)isEnable;

/**
 * When enabled, tracking data collected will be anonymized by the Google Analytics servers 
 * by zeroing out some of the least significant bits of the IP address.
 * In the case of IPv4 addresses, the last octet is set to zero. 
 * For IPv6 addresses, the last 10 octets are set to zero, although this is subject to change in the future.
 *
 * @param BOOL isEnable.
 */
- (void)setSendAnonymousEnabled:(BOOL)isEnable;

@end
