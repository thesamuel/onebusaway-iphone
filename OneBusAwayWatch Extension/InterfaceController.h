//
//  InterfaceController.h
//  OneBusAwayWatch Extension
//
//  Created by Sam Gehman on 7/26/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "OBARowController.h"
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

@interface InterfaceController : WKInterfaceController<WCSessionDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *stopsTable;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *modeGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *loadingLabel;

// Nearby tab
- (IBAction)nearbyPressed;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *nearbyGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *nearbyImage;

// Bookmarks tab
- (IBAction)bookmarksPressed;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *bookmarksGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *bookmarksImage;

@end
