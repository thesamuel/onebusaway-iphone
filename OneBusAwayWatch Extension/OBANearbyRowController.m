//
//  OBANearbyRowController.m
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/23/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "OBANearbyRowController.h"

@interface OBANearbyRowController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *stop;
@end

@implementation OBANearbyRowController

// TODO: create an object to hold this information

- (void)setName:(NSString *)name {
    [self.stop setText:name];
    _name = name;
}

@end
