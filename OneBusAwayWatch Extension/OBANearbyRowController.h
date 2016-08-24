//
//  OBANearbyRowController.h
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/23/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WatchKit;

@interface OBANearbyRowController : NSObject

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *stop;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *routes;

@end
