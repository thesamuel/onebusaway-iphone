//
//  InterfaceController.m
//  OneBusAwayWatch Extension
//
//  Created by Sam Gehman on 7/26/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController(){
    
}

@end

@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self refresh];
}

- (IBAction)refreshPressed {
    if ([self.table numberOfRows] > 1){
        NSRange rowRange = NSMakeRange(0, ([self.table numberOfRows]));
        NSIndexSet *rowIndexSet = [NSIndexSet indexSetWithIndexesInRange:rowRange];
        [self.table removeRowsAtIndexes:rowIndexSet];
    }
    [self refresh];
}

- (void)refresh {
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    if ([[WCSession defaultSession] isReachable]) {
        NSDictionary *request = @{@"request_type":@(OBAWatchRequestTypeNearby)};
        [[WCSession defaultSession] sendMessage:request
                                   replyHandler:^(NSDictionary<NSString *, id> *replyMessage) {
                                       [self updateNearbyWithMessage:replyMessage];
                                   }
                                   errorHandler:^(NSError *error) {
                                       // do something
                                   }
         ];
    } else {
        //phone unreachable
    }
}

- (void)updateNearbyWithMessage:(NSDictionary *)message {
    NSArray *nearbyArray = [message objectForKey:@"response"];
    for (NSDictionary *nearbyStop in nearbyArray) {
        NSInteger index = self.table.numberOfRows;
        [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withRowType:@"StopRow"];
        OBARowController *controller = [self.table rowControllerAtIndex:index];
        [controller.route setText:[nearbyStop objectForKey:@"---"]];
        [controller.stop setText:[nearbyStop objectForKey:@"name"]];
        [controller.status setText:@"n/a"];
    }
}

- (void)updateBookmarksWithMessage:(NSDictionary *)message {
    NSLog(@"Contents of connectivity message: \n%@", message);
    NSInteger index = self.table.numberOfRows;
    [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withRowType:@"StopRow"];
    OBARowController *controller = [self.table rowControllerAtIndex:index];
    if ([message objectForKey:@"bestAvailableName"]) {
        UIColor *departureStatusColor;
        switch ([[message objectForKey:@"departureStatus"] intValue]) {
            case 1: // early
                departureStatusColor = [UIColor greenColor];
                break;
            case 2: // on time
                departureStatusColor = [UIColor whiteColor];
                break;
            case 3: // delayed
                departureStatusColor = [UIColor blueColor];
                break;
            default:
                break;
        }
        [controller.route setText:[message objectForKey:@"bestAvailableName"]];
        [controller.stop setText:[message objectForKey:@"name"]];
        NSString *departureString = [NSString stringWithFormat:@"in %@ minutes", [message objectForKey:@"minutesUntilBestDeparture"]];
        [controller.status setText:departureString];
        if (departureStatusColor) {
            [controller.route setTextColor:departureStatusColor];
        }
    } else if (message) {
        [controller.route setText:@"--"];
        [controller.stop setText:[message objectForKey:@"name"]];
        [controller.status setText:@"none upcoming"];
    }
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end
