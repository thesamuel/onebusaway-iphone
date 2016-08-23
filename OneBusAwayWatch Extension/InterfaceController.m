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
@property (strong, nonatomic) NSDictionary *bookmarksMessage;
@property (strong, nonatomic) NSDictionary *nearbyMessage;

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

    [self setupUI];
    self.mode = kNearbyMode;
}

- (void)setupUI {
    [self.modeGroup setBackgroundColor:[UIColor clearColor]];
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
    [self requestNearby];
}

- (IBAction)bookmarksPressed {
    if (![self.mode isEqualToString:kBookmarksMode]) {
        self.mode = kBookmarksMode;
    }
    [self requestBookmarks];
}

- (void)setMode:(NSString *)mode {
    BOOL nearbyMode = [mode isEqualToString:kNearbyMode];

    // Begin updating rows
    [self.stopsTable setNumberOfRows:0 withRowType:@"StopRow"];
    (nearbyMode) ? [self requestNearby] : [self requestBookmarks];

    // Update Switch
    [self.nearbyImage setTintColor: (nearbyMode) ? [UIColor blackColor] : OBAGreen];
    [self.nearbyGroup setBackgroundColor:(nearbyMode) ? OBAGreen : [UIColor clearColor]];
    [self.bookmarksImage setTintColor:(nearbyMode) ? OBAGreen : [UIColor blackColor]];
    [self.bookmarksGroup setBackgroundColor:(nearbyMode) ? [UIColor clearColor] : OBAGreen];

    _mode = mode;
}

#pragma mark - Connectivity

// TODO: add automatic re-loading.
- (void)requestNearby {
    if (self.nearbyMessage) {
        [self updateNearbyWithMessage:self.nearbyMessage];
        //return; // TODO: remove this
    }

    [self.loadingLabel setHidden:NO];
    [self.stopsTable setHidden:YES];

    if ([[WCSession defaultSession] isReachable]) {
        NSDictionary *request = @{@"request_type":@(OBAWatchRequestTypeNearby)};
        [[WCSession defaultSession] sendMessage:request
                                   replyHandler:^(NSDictionary<NSString *, id> *replyMessage) {
                                       if ([self.mode isEqualToString:kNearbyMode]) {
                                           self.nearbyMessage = replyMessage;
                                           [self updateNearbyWithMessage:replyMessage];
                                       }
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
    if (self.bookmarksMessage) {
        [self updateBookmarksWithMessage:self.bookmarksMessage];
        return;
    }

    [self.loadingLabel setHidden:NO];
    [self.stopsTable setHidden:YES];

    if ([[WCSession defaultSession] isReachable]) {
        NSDictionary *request = @{@"request_type":@(OBAWatchRequestTypeBookmarks)};
        [[WCSession defaultSession] sendMessage:request
                                   replyHandler:^(NSDictionary<NSString *, id> *replyMessage) {
                                       if ([self.mode isEqualToString:kBookmarksMode]) {
                                           self.bookmarksMessage = replyMessage;
                                           [self updateBookmarksWithMessage:replyMessage];
                                       }
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
    NSArray *nearbys = [message objectForKey:@"response"];
    NSUInteger numberOfRows = nearbys.count;
    [self.stopsTable setNumberOfRows:numberOfRows withRowType:@"StopRow"];
    for (int i = 0; i < numberOfRows; i++) {
        OBARowController *controller = [self.stopsTable rowControllerAtIndex:i];
        [controller.route setText:[nearbys[i] objectForKey:@"---"]];
        [controller.stop setText:[nearbys[i] objectForKey:@"name"]];
        [controller.status setText:@"n/a"];
    }
    [self.loadingLabel setHidden:YES];
    [self.stopsTable setHidden:NO];
}

// TODO: data is now sent as a package. update accordingly.
- (void)updateBookmarksWithMessage:(NSDictionary *)message {
    NSArray *bookmarks = [message objectForKey:@"response"];
    NSUInteger numberOfRows = bookmarks.count;
    [self.stopsTable setNumberOfRows:numberOfRows withRowType:@"StopRow"];
    for (int i = 0; i < numberOfRows; i++) {
        OBARowController *controller = [self.stopsTable rowControllerAtIndex:i];
        if ([bookmarks[i] objectForKey:@"bestAvailableName"]) {
            UIColor *departureStatusColor;
            switch ([[bookmarks[i] objectForKey:@"departureStatus"] intValue]) {
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
            [controller.route setText:[bookmarks[i] objectForKey:@"bestAvailableName"]];
            [controller.stop setText:[bookmarks[i] objectForKey:@"name"]];
            NSString *departureString = [NSString stringWithFormat:@"in %@ minutes", [bookmarks[i] objectForKey:@"minutesUntilBestDeparture"]];
            [controller.status setText:departureString];
            if (departureStatusColor) {
                [controller.route setTextColor:departureStatusColor];
            }
        } else {
            [controller.route setText:@"--"];
            [controller.stop setText:[bookmarks[i] objectForKey:@"name"]];
            [controller.status setText:@"none upcoming"];
        }
    }
    [self.loadingLabel setHidden:YES];
    [self.stopsTable setHidden:NO];
}

@end
