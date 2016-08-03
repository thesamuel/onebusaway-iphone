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

static NSUInteger const kOBAWatchBookmarkMinutesAfter = 120;
static double const kOBANearbyRadiusInMeters = 2000; // 2 kilometers

@interface OBAWatchManager () {
    MKCoordinateRegion region;
}

@property (nonatomic, strong) id<OBAModelServiceRequest> request;
@property (nonatomic, strong) OBAModelService *modelService;

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
    CLLocation *location = lm.currentLocation;

    if (location) {
        //double radius = MAX(location.horizontalAccuracy, OBAMinMapRadiusInMeters);
        region = [OBASphericalGeometryLibrary createRegionWithCenter:location.coordinate
                                                           latRadius:kOBANearbyRadiusInMeters
                                                           lonRadius:kOBANearbyRadiusInMeters];
    }
}

- (NSArray *)nearbyStops {
    [self refreshCurrentRegion];
    __block NSArray *stops;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    _request = [_modelService requestStopsForRegion:region completionBlock:^(id jsonData, NSUInteger responseCode, NSError *error) {
        //TODO: get this wrapper to work! (error codes)
        //WrapperCompletion(jsonData, responseCode, error, ^(id data) {
        stops = [self arrayOfNearbyStopsWithJson:jsonData];
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return stops;
}

- (NSArray *)arrayOfNearbyStopsWithJson:(OBAListWithRangeAndReferencesV2 *)list {
    //OBASearchResult *result = [OBASearchResult resultFromList:list];
    NSMutableArray *stopsArray = [NSMutableArray new];
    for (OBAStopV2 *stop in list.values) {
        NSDictionary *stopDictionary = @{@"stopName":stop.name,
                                       @"stopId":stop.code,
                                       @"stopDirection":stop.direction,
                                       @"name":[NSString stringWithFormat:@"%@ [%@]", stop.name, stop.direction]};
        [stopsArray addObject:stopDictionary];
    }
    return stopsArray;
}

#pragma mark - Bookmark Methods

- (NSArray *)bookmarks {
    OBAModelDAO *modelDAO = [OBAApplication sharedApplication].modelDao;
    NSMutableArray *allBookmarks = [NSMutableArray new];
    [allBookmarks addObjectsFromArray:modelDAO.ungroupedBookmarks];
    for (OBABookmarkGroup *group in modelDAO.bookmarkGroups) {
        [allBookmarks addObjectsFromArray:group.bookmarks];
    }

    __block NSMutableArray* bookmarkArray;
    for (OBABookmarkV2 *bookmark in allBookmarks) {
        [[OBAApplication sharedApplication].modelService requestStopForID:bookmark.stopId
                                                            minutesBefore:0
                                                             minutesAfter:kOBAWatchBookmarkMinutesAfter].then(^(OBAArrivalsAndDeparturesForStopV2 *response) {
            NSArray<OBAArrivalAndDepartureV2*> *matchingDepartures = [bookmark matchingArrivalsAndDeparturesForStop:response];
            OBAArrivalAndDepartureV2 *nextDeparture = matchingDepartures.firstObject;
            [bookmarkArray addObject:[self createDictionaryForBookmark:bookmark withArrivalAndDeparture:nextDeparture]];
        }).catch(^(NSError *error) {
            NSLog(@"Failed to load departure for bookmark: %@", error);
        });
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
