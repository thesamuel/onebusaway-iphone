//
//  OBAStopInterfaceController.m
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/24/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "OBAStopInterfaceController.h"
#import "OBANearbyRowController.h"

@interface OBAStopInterfaceController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *name;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceMap *map;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *busTable;
@end

@implementation OBAStopInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    OBANearbyRowController *rowController = (OBANearbyRowController *)context;
    [self.name setText:rowController.name];

    CLLocationCoordinate2D mapLocation = CLLocationCoordinate2DMake(37, -122);
    MKCoordinateSpan coordinateSpan = MKCoordinateSpanMake(1, 1);
    [self.map setRegion:MKCoordinateRegionMake(mapLocation, coordinateSpan)];
}

@end
