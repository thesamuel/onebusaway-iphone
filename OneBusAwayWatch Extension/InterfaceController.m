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
        //phone isnt there
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message {
//    NSDictionary *replyDictionary = @{@"bestAvailableName":nextDeparture.bestAvailableName,
//                                      @"departureStatus":@(nextDeparture.departureStatus),
//                                      @"statusText":nextDeparture.statusText,
//                                      @"minutesUntilBestDeparture":@(nextDeparture.minutesUntilBestDeparture)};
    
    NSLog(@"THIS IS THE LOG OF THE ENTIRE MESSAGE: \n%@", message);
    NSInteger index = self.table.numberOfRows;
    [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withRowType:@"TestRow"];
    OBARowController *controller = [self.table rowControllerAtIndex:index];
    [controller.label setText:[message objectForKey:@"bestAvailableName"]];
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



