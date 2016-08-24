//
//  CLLocation+OBABearing.h
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/23/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

#define DEGREES_TO_RADIANS(degrees) ((M_PI * degrees) / 180.0)
#define RADIANS_TO_DEGREES(radians) (radians * 180.0 / M_PI)

typedef enum {
    CLLocationBearingNorth,
    CLLocationBearingNorthEast,
    CLLocationBearingEast,
    CLLocationBearingSouthEast,
    CLLocationBearingSouth,
    CLLocationBearingSouthWest,
    CLLocationBearingWest,
    CLLocationBearingNorthWest,
    CLLocationBearingUnknown = -999,
} CLLocationBearing;

/*
 *  NSLocalizedStringFromBearing
 * 
 *  Returns a localized string representing the cardinal
 *  bearing.
 */
NSString *NSLocalizedStringFromBearing(CLLocationBearing bearing);

@interface CLLocation (OBABearing)

/*
 *  bearingToLocation:
 *
 *  Discussion:
 *    Returns the bearing from one location to another.
 */
- (CLLocationBearing)bearingToLocation:(const CLLocation *)location;

@end
