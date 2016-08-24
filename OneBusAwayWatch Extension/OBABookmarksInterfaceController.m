//
//  InterfaceController.m
//  OneBusAwayWatch Extension
//
//  Created by Sam Gehman on 7/26/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "OBABookmarksInterfaceController.h"

@interface OBABookmarksInterfaceController()

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *bookmarkStopsTable;

@end

@implementation OBABookmarksInterfaceController

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [OBAConnectivityManager sharedInstance].bookmarksDelegate = self;
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [[OBAConnectivityManager sharedInstance] requestBookmarks]; // TODO: add more calls
}

- (void)willActivate {
    [[OBAConnectivityManager sharedInstance] requestBookmarks]; // TODO: add more calls
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

#pragma mark - Connectivity

//    if (self.bookmarksMessage) {
//        [self updateBookmarksWithMessage:self.bookmarksMessage];
//        return;
//    }
//    [self.bookmarkStopsTable setHidden:YES];
//    self.bookmarksMessage = replyMessage;

- (void)updateBookmarksWithMessage:(NSDictionary *)message {
    NSArray *bookmarks = [message objectForKey:@"response"];
    NSUInteger numberOfRows = bookmarks.count;
    [self.bookmarkStopsTable setNumberOfRows:numberOfRows withRowType:@"BookmarkStopRow"];
    for (int i = 0; i < numberOfRows; i++) {
        OBABookmarkRowController *controller = [self.bookmarkStopsTable rowControllerAtIndex:i];
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
}

@end
