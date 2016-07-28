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
//    replyDictionary = @{@"bestAvailableName":nextDeparture.bestAvailableName,
//                        @"departureStatus":@(nextDeparture.departureStatus),
//                        @"minutesUntilBestDeparture":@(nextDeparture.minutesUntilBestDeparture),
//                        @"stopName":bookmark.stop.name,
//                        @"stopDirection":bookmark.stop.direction,
//                        @"name":bookmark.name,
//                        @"deviationFromSchedule":@(nextDeparture.predictedDepatureTimeDeviationFromScheduleInMinutes)};
    
//    OBADepartureStatusUnknown = 0,
//    OBADepartureStatusEarly,
//    OBADepartureStatusOnTime,
//    OBADepartureStatusDelayed
    
    NSLog(@"Contents of connectivity message: \n%@", message);
    NSInteger index = self.table.numberOfRows;
    [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withRowType:@"TestRow"];
    OBARowController *controller = [self.table rowControllerAtIndex:index];
    if ([message objectForKey:@"bestAvailableName"]) {
        NSArray *labelArray = @[[message objectForKey:@"bestAvailableName"], //0
                                [message objectForKey:@"departureStatus"], //1
                                [message objectForKey:@"minutesUntilBestDeparture"], //2
                                [message objectForKey:@"stopName"], //3
                                [message objectForKey:@"stopDirection"], //4
                                [message objectForKey:@"name"], //5
                                [message objectForKey:@"deviationFromSchedule"]]; //6
        
        NSString *departureStatus;
        int test = [[message objectForKey:@"departureStatus"] intValue];
        switch (test) {
            case 0:
                departureStatus = @"Unknown Departure";
                break;
            case 1:
                departureStatus = @"Early Departure";
                break;
            case 2:
                departureStatus = @"On Time Departure";
                break;
            case 3:
                departureStatus = @"Delayed Departure";
                break;
            default:
                departureStatus = @"Problem loading departure";
                break;
        }
        
        NSString *labelString = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@",
                                 labelArray[0],
                                 departureStatus,
                                 labelArray[2],
                                 labelArray[3],
                                 labelArray[4],
                                 labelArray[5],
                                 labelArray[6]
                                 ];
        
        [controller.label setText:labelString];
    } else if (message) {
        [controller.label setText:[message objectForKey:@"name"]];
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



