//
//  OBANearbyInterfaceController.h
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/23/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import "OBAConnectivityManager.h"
#import "OBANearbyRowController.h"

@interface OBANearbyInterfaceController : WKInterfaceController<WatchConnectivityNearbyDelegate>

- (void)updateNearbyWithMessage:(NSDictionary *)message;

@end
