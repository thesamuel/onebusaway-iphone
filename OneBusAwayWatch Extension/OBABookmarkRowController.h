//
//  OBABookmarkRowController.h
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 7/26/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <Foundation/Foundation.h>
@import WatchKit;

@interface OBABookmarkRowController : NSObject

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *route;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *stop;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *status;

@end
