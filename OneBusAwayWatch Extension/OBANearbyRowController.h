//
//  OBANearbyRowController.h
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/23/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WatchKit;
@import MapKit;

@interface OBANearbyRowController : NSObject

@property (strong, nonatomic) NSString *name;
@property (nonatomic) MKCoordinateRegion region;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *routes;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *distance;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *bearing;

@end
