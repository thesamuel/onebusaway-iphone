//
//  OBAStopInterfaceController.m
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/24/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "OBAStopInterfaceController.h"

@interface OBAStopInterfaceController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *name;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceMap *map;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *busTable;
@end

@implementation OBAStopInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self.name setText:[context objectForKey:@"name"]];
}

@end
