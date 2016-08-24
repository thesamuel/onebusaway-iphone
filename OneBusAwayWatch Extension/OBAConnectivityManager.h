//
//  OBAConnectivityManager.h
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/23/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WatchConnectivity;

// TODO: sam - declare a common class for these with watch app
typedef NS_ENUM(NSInteger, OBAWatchRequestType) {
    OBAWatchRequestTypeNearby,
    OBAWatchRequestTypeBookmarks,
    OBAWatchRequestTypeCurrentMap,
};

typedef NS_ENUM(NSInteger, OBAWatchResponseType) {
    OBAWatchResponseTypeNearby,
    OBAWatchResponseTypeBookmarks,
    OBAWatchResponseTypeCurrentMap,
};

@protocol WatchConnectivityBookmarksDelegate <NSObject>
- (void)updateBookmarksWithMessage:(NSDictionary *)message;
@end


@protocol WatchConnectivityNearbyDelegate <NSObject>
- (void)updateNearbyWithMessage:(NSDictionary *)message;
@end


@interface OBAConnectivityManager : NSObject<WCSessionDelegate>

@property (weak, nonatomic) id<WatchConnectivityBookmarksDelegate> bookmarksDelegate;
@property (weak, nonatomic) id<WatchConnectivityNearbyDelegate> nearbyDelegate;

+ (instancetype)sharedInstance;

- (void)requestBookmarks;
- (void)requestNearby;

@end
