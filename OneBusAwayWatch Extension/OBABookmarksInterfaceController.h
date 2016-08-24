//
//  InterfaceController.h
//  OneBusAwayWatch Extension
//
//  Created by Sam Gehman on 7/26/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "OBAConnectivityManager.h"
#import "OBABookmarkRowController.h"

@interface OBABookmarksInterfaceController : WKInterfaceController<WatchConnectivityBookmarksDelegate>

- (void)updateBookmarksWithMessage:(NSDictionary *)message;

@end
