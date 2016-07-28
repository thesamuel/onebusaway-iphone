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

@interface InterfaceController : WKInterfaceController<WCSessionDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *table;
- (IBAction)refreshPressed;

@end
