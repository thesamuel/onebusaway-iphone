//
//  OBAWatchManager.h
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/1/16.
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

@interface OBAWatchManager : NSObject <WCSessionDelegate>

@end
