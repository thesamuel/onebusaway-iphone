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
@property (strong, nonatomic) NSArray *savedBookmarks;

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
    if ([self.savedBookmarks isEqualToArray:bookmarks]) {
        return;
    }
    NSUInteger numberOfRows = bookmarks.count;
    [self.bookmarkStopsTable setNumberOfRows:numberOfRows withRowType:@"BookmarkStopRow"];
    for (int i = 0; i < numberOfRows; i++) {
        OBABookmarkRowController *controller = [self.bookmarkStopsTable rowControllerAtIndex:i];
        if ([bookmarks[i] objectForKey:@"bestAvailableName"]) {
            [controller.route setText:[bookmarks[i] objectForKey:@"bestAvailableName"]];
            [controller.stop setText:[bookmarks[i] objectForKey:@"name"]];
            NSString *departureString = [NSString stringWithFormat:@"in %@ minutes", [bookmarks[i] objectForKey:@"minutesUntilBestDeparture"]];
            [controller.status setText:departureString];
            UIColor *departureStatusColor = [self colorForBookmark:bookmarks[i]];
            if (departureStatusColor) {
                [controller.route setTextColor:departureStatusColor];
            }
        } else {
            [controller.route setText:@"--"];
            [controller.stop setText:[bookmarks[i] objectForKey:@"name"]];
            [controller.status setText:@"none upcoming"];
        }
    }
    self.savedBookmarks = bookmarks;
}

- (UIColor *)colorForBookmark:(NSDictionary *)bookmark {
    switch ([[bookmark objectForKey:@"departureStatus"] intValue]) {
        case 1: // early
            return [UIColor greenColor];
        case 2: // on time
            return [UIColor whiteColor];
        case 3: // delayed
            return [UIColor blueColor];
        default:
            break;
    }
    return nil;
}

@end
