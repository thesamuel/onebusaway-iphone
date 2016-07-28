//
//  InterfaceController.m
//  OneBusAwayWatch Extension
//
//  Created by Sam Gehman on 7/26/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
    
    if ([[WCSession defaultSession] isReachable]) {
        NSDictionary *applicationDict = @{@"launched": @"true"};
        [[WCSession defaultSession] sendMessage:applicationDict
                                   replyHandler:nil
                                   errorHandler:nil];
    } else {
        //phone unreachable
    }
}

// message dictionary: bestAvailableName, departureStatus, minutesUntilBestDeparture, name, deviationFromSchedule
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message {
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
        NSString *departureString = [NSString stringWithFormat:@"%@ minutes", [message objectForKey:@"minutesUntilBestDeparture"]];
        [controller.status setText:departureString];
        if (departureStatusColor) {
            [controller.route setTextColor:departureStatusColor];
        }
    } else if (message) {
        [controller.route setText:@"--"];
        [controller.stop setText:[message objectForKey:@"name"]];
        [controller.status setText:@"no upcoming transit"];
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



