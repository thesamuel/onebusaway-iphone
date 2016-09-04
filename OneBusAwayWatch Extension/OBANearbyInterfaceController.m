//
//  OBANearbyInterfaceController.m
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/23/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "OBANearbyInterfaceController.h"

@interface OBANearbyInterfaceController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *nearbyStopsTable;

@end

@implementation OBANearbyInterfaceController

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [OBAConnectivityManager sharedInstance].nearbyDelegate = self;
    }
    return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [[OBAConnectivityManager sharedInstance] requestNearby];
}

- (void)willActivate {
    [[OBAConnectivityManager sharedInstance] requestNearby];
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)updateNearbyWithMessage:(NSDictionary *)message {
    NSArray *nearbys = [message objectForKey:@"response"];
    NSUInteger numberOfRows = nearbys.count;
    [self.nearbyStopsTable setNumberOfRows:numberOfRows withRowType:@"NearbyStopRow"];
    for (int i = 0; i < numberOfRows; i++) {
        OBANearbyRowController *controller = [self.nearbyStopsTable rowControllerAtIndex:i];
        controller.name = [nearbys[i] objectForKey:@"name"];
        [controller.routes setText:[nearbys[i] objectForKey:@"routes"]];
        MKDistanceFormatter *distanceFormatter = [MKDistanceFormatter new];
        NSString *distanceString = [distanceFormatter stringFromDistance:[[nearbys[i] objectForKey:@"distance"] doubleValue]];
        [controller.distance setText:[NSString stringWithFormat:@"%@ away", distanceString]];
        [controller.bearing setText:[nearbys[i] objectForKey:@"bearing"]];
        MKCoordinateRegion region;
        [[nearbys[i] objectForKey:@"region"] getBytes:&region length:sizeof(region)];
        controller.region = region;
    }
}

- (void)table:(WKInterfaceTable *)table didSelectRowAtIndex:(NSInteger)rowIndex {
    OBANearbyRowController *rowController = [self.nearbyStopsTable rowControllerAtIndex:rowIndex];
    //NSDictionary *context = @{@"name":rowController.name, @"region":rowController.region};
    [self presentControllerWithName:@"StopInterfaceController" context:rowController];
}

@end
