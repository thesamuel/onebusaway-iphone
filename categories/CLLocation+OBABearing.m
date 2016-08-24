//
//  CLLocation+OBABearing.m
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/23/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "CLLocation+OBABearing.h"

NSString *NSLocalizedStringFromBearing(CLLocationBearing bearing) {
    NSString *key = nil;
    switch (bearing) {
        case CLLocationBearingEast:
            key = @"E";
            break;
        case CLLocationBearingNorth:
            key = @"N";
            break;
        case CLLocationBearingNorthEast:
            key = @"NE";
            break;
        case CLLocationBearingNorthWest:
            key = @"NW";
            break;
        case CLLocationBearingSouth:
            key = @"S";
            break;
        case CLLocationBearingSouthEast:
            key = @"SE";
            break;
        case CLLocationBearingSouthWest:
            key = @"SW";
            break;
        case CLLocationBearingWest:
            key = @"W";
            break;
        case CLLocationBearingUnknown:
            key = @"?";
            break;
        default:
            key = @"?";
            break;
    }

    return NSLocalizedString(key, nil);
}

@implementation CLLocation (OBABearing)

- (CLLocationBearing)bearingToLocation:(const CLLocation *)location {
    double lat1 = DEGREES_TO_RADIANS(self.coordinate.latitude);
    double lon1 = DEGREES_TO_RADIANS(self.coordinate.longitude);

    double lat2 = DEGREES_TO_RADIANS(location.coordinate.latitude);
    double lon2 = DEGREES_TO_RADIANS(location.coordinate.longitude);

    double dLon = lon2 - lon1;

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    double radiansBearing = atan2(y, x);

    if (radiansBearing < 0.0) {
        radiansBearing += 2 * M_PI;
    }
    double degreesBearing = RADIANS_TO_DEGREES(radiansBearing);
    degreesBearing = (int)degreesBearing % 360;
    return round(degreesBearing / 45.0);
}

@end
