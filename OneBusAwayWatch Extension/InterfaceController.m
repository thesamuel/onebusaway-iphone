//
//  InterfaceController.m
//  OneBusAwayWatch Extension
//
//  Created by Sam Gehman on 7/26/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "InterfaceController.h"

UIColor *OBAGreen = nil;
NSString *const kNearbyMode = @"nearby";
NSString *const kBookmarksMode = @"bookmarks";

@interface InterfaceController()
@property (nonatomic) NSString *mode;
@end

@implementation InterfaceController

#pragma mark - Life Cycles

+ (void)initialize {
    if (self == [InterfaceController class]) {
        if (!OBAGreen) {
            OBAGreen = [UIColor colorWithRed:0.47 green:0.67 blue:0.21 alpha:1.0];
        }
    }
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }

    [self setupImages];
    self.mode = kNearbyMode;
}

- (void)setupImages {
    UIImage *nearbyPNG = [UIImage imageNamed:@"Near Me Filled-50.png"];
    nearbyPNG = [nearbyPNG imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.nearbyImage setImage:nearbyPNG];

    UIImage *bookmarksPNG = [UIImage imageNamed:@"Bookmark Ribbon Filled-50.png"];
    bookmarksPNG = [bookmarksPNG imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.bookmarksImage setImage:bookmarksPNG];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Mode Switching Methods

- (IBAction)nearbyPressed {
    if (![self.mode isEqualToString:kNearbyMode]) {
        self.mode = kNearbyMode;
    }
}

- (IBAction)bookmarksPressed {
    if (![self.mode isEqualToString:kBookmarksMode]) {
        self.mode = kBookmarksMode;
    }
}

- (void)setMode:(NSString *)mode {
    BOOL nearbyMode = [mode isEqualToString:kNearbyMode];

    // Begin updating rows
    [self.table setNumberOfRows:0 withRowType:@"StopRow"];
    (nearbyMode) ? [self requestNearby] : [self requestBookmarks];

    // Update Switch
    [self.nearbyImage setTintColor: (nearbyMode) ? [UIColor blackColor] : OBAGreen];
    [self.nearbyGroup setBackgroundColor:(nearbyMode) ? OBAGreen : [UIColor blackColor]];
    [self.bookmarksImage setTintColor:(nearbyMode) ? OBAGreen : [UIColor blackColor]];
    [self.bookmarksGroup setBackgroundColor:(nearbyMode) ? [UIColor blackColor] : OBAGreen];

    _mode = mode;
}

#pragma mark - Connectivity

- (void)requestNearby {
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



- (void)requestBookmarks {
    if ([[WCSession defaultSession] isReachable]) {
        NSDictionary *request = @{@"request_type":@(OBAWatchRequestTypeNearby)};
        [[WCSession defaultSession] sendMessage:request
                                   replyHandler:^(NSDictionary<NSString *, id> *replyMessage) {
                                       [self updateBookmarksWithMessage:replyMessage];
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

@end
