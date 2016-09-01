//
//  OBAWatchManager.m
//  org.onebusaway.iphone
//
//  Created by Sam Gehman on 8/1/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "OBAWatchManager.h"
#import "OBAKit.h"
#import "OBASearchController.h"
#import "CLLocation+OBABearing.h"
#import "OBALocationModel.h"

static NSUInteger const kOBAWatchBookmarkMinutesAfter = 120;
static double const kOBANearbyRadiusInMeters = 1000; // 1 kilometer

@interface OBAWatchManager ()

@property (nonatomic, strong) id<OBAModelServiceRequest> request;
@property (nonatomic, strong) OBAModelService *modelService;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic) MKCoordinateRegion region;

@end

@implementation OBAWatchManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _modelService = [OBAApplication sharedApplication].modelService;
        [self setupWatchConnectivity];
        [self refreshCurrentRegion];
    }
    return self;
}

- (void)setupWatchConnectivity {
    if ([WCSession isSupported]) {
        WCSession* session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message
   replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler {
    OBAWatchRequestType requestType = [[message objectForKey:@"request_type"] integerValue];
    if (requestType == OBAWatchRequestTypeNearby) {
        //[self nearbyStops]
        NSDictionary *messageDictionary = @{@"response":[self nearbyStops],
                                            @"response_type":@(OBAWatchResponseTypeNearby)};
        replyHandler(messageDictionary);
    } else if (requestType == OBAWatchRequestTypeBookmarks) {
        NSDictionary *messageDictionary = @{@"response":[self bookmarks],
                                            @"response_type":@(OBAWatchResponseTypeBookmarks)};
        replyHandler(messageDictionary);
    }
}

#pragma mark - Nearby Methods

- (void)refreshCurrentRegion {
    OBALocationManager *lm = [OBAApplication sharedApplication].locationManager;
    self.lastLocation = lm.currentLocation;

    if (self.lastLocation) {
        //double radius = MAX(location.horizontalAccuracy, OBAMinMapRadiusInMeters);
        self.region = [OBASphericalGeometryLibrary createRegionWithCenter:self.lastLocation.coordinate
                                                                latRadius:kOBANearbyRadiusInMeters
                                                                lonRadius:kOBANearbyRadiusInMeters];
    }
}

- (NSArray *)nearbyStops {
    [self refreshCurrentRegion];
    __block NSArray *stops;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    _request = [_modelService requestStopsForRegion:self.region completionBlock:^(id jsonData, NSUInteger responseCode, NSError *error) {
        //TODO: get this wrapper to work! (error codes)
        //WrapperCompletion(jsonData, responseCode, error, ^(id data) {
        stops = [self arrayOfNearbyStopsWithJson:jsonData];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return stops;
}

// TODO: send modelsq
- (NSArray *)arrayOfNearbyStopsWithJson:(OBAListWithRangeAndReferencesV2 *)list {
    //OBASearchResult *result = [OBASearchResult resultFromList:list];
//    NSArray *sortedList = [self sortStopsByDistance:list.values];
    NSMutableArray *stopsArray = [NSMutableArray new];
    for (OBAStopV2 *stop in list.values) {
        if (stop.name && stop.code) { // TODO: remove this.
            NSMutableDictionary *stopDictionary = [NSMutableDictionary new];
            [stopDictionary setObject:stop.name forKey:@"stopName"];
            [stopDictionary setObject:stop.code forKey:@"stopId"];
            [stopDictionary setObject:stop.routeNamesAsString forKey:@"routes"];
            CLLocationDistance distanceFromCurrentLocation = [stop.location distanceFromLocation:self.lastLocation];
            [stopDictionary setObject:[NSNumber numberWithDouble:distanceFromCurrentLocation] forKey:@"distance"];
            CLLocationBearing bearing = [self.lastLocation bearingToLocation:stop.location];
            [stopDictionary setObject:NSLocalizedStringFromBearing(bearing) forKey:@"bearing"];
            if (stop.direction) {
                [stopDictionary setObject:stop.direction forKey:@"stopDirection"];
            }
            NSString *name = (stop.direction) ? [NSString stringWithFormat:@"%@ [%@]", stop.name, stop.direction] : stop.name;
            [stopDictionary setObject:name forKey:@"name"];

            // Create region NSData
            MKCoordinateRegion region = [OBASphericalGeometryLibrary createRegionWithCenter:stop.coordinate
                                                                                  latRadius:kOBANearbyRadiusInMeters
                                                                                  lonRadius:kOBANearbyRadiusInMeters];
            NSData *regionData = [NSData dataWithBytes:&region length:sizeof(region)];
            [stopDictionary setObject:regionData forKey:@"region"];

            // Add stop to the array
            [stopsArray addObject:stopDictionary];
        }
    }
    NSLog(@"CURRENT_LOCATION: %@", self.lastLocation);
    NSLog(@"\n\nWATCH_STOPS:%@", stopsArray);
    NSSortDescriptor *sortByDistance = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    [stopsArray sortUsingDescriptors:@[sortByDistance]];
    NSLog(@"\n\nSORTED_WATCH_STOPS:%@", stopsArray);
    return stopsArray;
}

//- (NSArray *)sortStopsByDistance:(NSArray *)stops {
////    return [stops sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
////        OBAStopV2 *stop1 = obj1, *stop2 = obj2;
////        CLLocationDistance d1 = [stop1.location distanceFromLocation:self.lastLocation];
////        CLLocationDistance d2 = [stop2.location distanceFromLocation:self.lastLocation];
////        return d1 < d2 ? NSOrderedAscending : d1 > d2 ? NSOrderedDescending : NSOrderedSame;
////    }];
//}

#pragma mark - Bookmark Methods
// TODO: figure out semaphores
- (NSArray *)bookmarks {
    OBAModelDAO *modelDAO = [OBAApplication sharedApplication].modelDao;
    NSMutableArray *allBookmarks = [NSMutableArray new];
    [allBookmarks addObjectsFromArray:modelDAO.ungroupedBookmarks];
    for (OBABookmarkGroup *group in modelDAO.bookmarkGroups) {
        [allBookmarks addObjectsFromArray:group.bookmarks];
    }

    __block NSMutableArray* bookmarkArray = [NSMutableArray new];
    for (OBABookmarkV2 *bookmark in allBookmarks) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[OBAApplication sharedApplication].modelService requestStopForID:bookmark.stopId
                                                            minutesBefore:0
                                                             minutesAfter:kOBAWatchBookmarkMinutesAfter].then(^(OBAArrivalsAndDeparturesForStopV2 *response) {
            NSArray<OBAArrivalAndDepartureV2*> *matchingDepartures = [bookmark matchingArrivalsAndDeparturesForStop:response];
            OBAArrivalAndDepartureV2 *nextDeparture = matchingDepartures.firstObject;
            [bookmarkArray addObject:[self createDictionaryForBookmark:bookmark withArrivalAndDeparture:nextDeparture]];
            dispatch_semaphore_signal(semaphore);
        }).catch(^(NSError *error) {
            NSLog(@"Failed to load departure for bookmark: %@", error);
            dispatch_semaphore_signal(semaphore);
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    return bookmarkArray;
}

- (NSDictionary *)createDictionaryForBookmark:(OBABookmarkV2 *)bookmark withArrivalAndDeparture:(OBAArrivalAndDepartureV2 *)nextDeparture {
    NSDictionary *replyDictionary;
    if (nextDeparture) {
        replyDictionary = @{@"stopDirection":bookmark.stop.direction,
                            @"name":bookmark.name,
                            @"stopName":bookmark.stop.name,
                            @"bestAvailableName":nextDeparture.bestAvailableName,
                            @"departureStatus":@(nextDeparture.departureStatus),
                            @"minutesUntilBestDeparture":@(nextDeparture.minutesUntilBestDeparture),
                            @"deviationFromSchedule":@(nextDeparture.predictedDepatureTimeDeviationFromScheduleInMinutes)};
    } else {
        replyDictionary = @{@"name":bookmark.name};
    }
    return replyDictionary;
}

@end
