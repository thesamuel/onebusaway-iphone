//
//  OBAConnectivityManager.m
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/23/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "OBAConnectivityManager.h"

@implementation OBAConnectivityManager

+ (instancetype)sharedInstance {
    static OBAConnectivityManager *connectivityManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connectivityManager = [[self alloc] init];
    });
    return connectivityManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([WCSession isSupported]) {
            WCSession* session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
        }
    }
    return self;
}

- (void)requestBookmarks {
    if ([[WCSession defaultSession] isReachable]) {
        NSDictionary *request = @{@"request_type":@(OBAWatchRequestTypeBookmarks)};
        [[WCSession defaultSession] sendMessage:request
                                   replyHandler:^(NSDictionary<NSString *, id> *replyMessage) {
                                       NSAssert(self.bookmarksDelegate, @"Bookmarks delegate did not exist");
                                       [self.bookmarksDelegate updateBookmarksWithMessage:replyMessage];
                                   }
                                   errorHandler:^(NSError *error) {
                                       // TODO: refresh
                                       // ignore error code...
                                   }
         ];
    } else {
        // TODO: present alert
    }
}

- (void)requestNearby {
    if ([[WCSession defaultSession] isReachable]) {
        NSDictionary *request = @{@"request_type":@(OBAWatchRequestTypeNearby)};
        [[WCSession defaultSession] sendMessage:request
                                   replyHandler:^(NSDictionary<NSString *, id> *replyMessage) {
                                       NSAssert(self.nearbyDelegate, @"Nearby delegate did not exist");
                                       [self.nearbyDelegate updateNearbyWithMessage:replyMessage];
                                   }
                                   errorHandler:^(NSError *error) {
                                       // TODO: refresh
                                       // ignore error code...
                                   }
         ];
    } else {
        // TODO: present alert
    }
}

@end
