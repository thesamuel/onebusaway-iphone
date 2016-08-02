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

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message {
    OBAWatchRequestType requestType = [[message objectForKey:@"requestType"] integerValue];
    if (requestType == OBAWatchRequestTypeNearby) {
        [self refreshNearbyStops];
    } else if (requestType == OBAWatchRequestTypeBookmarks) {

    }
}

- (void)sendMessage:(NSDictionary *)message {
    if (message) {
        if ([[WCSession defaultSession] isReachable]) {
            [[WCSession defaultSession] sendMessage:message replyHandler:nil errorHandler:nil];
        } else {
            //watch isnt there
        }
    }
}

#pragma mark - Nearby Methods

- (void)refreshCurrentRegion {
    OBALocationManager *lm = [OBAApplication sharedApplication].locationManager;
    CLLocation *location = lm.currentLocation;

    if (location) {
        double radius = MAX(location.horizontalAccuracy, OBAMinMapRadiusInMeters);
        region = [OBASphericalGeometryLibrary createRegionWithCenter:location.coordinate latRadius:radius lonRadius:radius];
    }
}

- (void)refreshNearbyStops {
    [self refreshCurrentRegion];
    _request = [_modelService requestStopsForRegion:region completionBlock:^(id jsonData, NSUInteger responseCode, NSError *error) {
        //TODO: get this wrapper to work! (error codes)
        //WrapperCompletion(jsonData, responseCode, error, ^(id data) {
        [self sendNearbyStops:jsonData];
    }];
}

- (void)sendNearbyStops:(OBAListWithRangeAndReferencesV2 *)list {
    //OBASearchResult *result = [OBASearchResult resultFromList:list];
    NSMutableDictionary *stopDictionary = [NSMutableDictionary new];
    for (OBAStopV2 *stop in list.values) {
        [stopDictionary setObject:stop.name forKey:@"stopName"];
        [stopDictionary setObject:stop.code forKey:@"stopId"];
        [stopDictionary setObject:stop.direction forKey:@"stopDirection"];
        [stopDictionary setObject:[NSString stringWithFormat:@"%@ [%@]", stop.name, stop.direction] forKey:@"name"];
        [self sendMessage:stopDictionary];
    }
}

#pragma mark - Bookmark Methods

- (void)refreshBookmarks {
    OBAModelDAO *modelDAO = [OBAApplication sharedApplication].modelDao;
    NSMutableArray *allBookmarks = [NSMutableArray new];
    [allBookmarks addObjectsFromArray:modelDAO.ungroupedBookmarks];
    for (OBABookmarkGroup *group in modelDAO.bookmarkGroups) {
        [allBookmarks addObjectsFromArray:group.bookmarks];
    }

    for (OBABookmarkV2 *bookmark in allBookmarks) {
        [[OBAApplication sharedApplication].modelService requestStopForID:bookmark.stopId
                                                            minutesBefore:0
                                                             minutesAfter:kOBAWatchBookmarkMinutesAfter].then(^(OBAArrivalsAndDeparturesForStopV2 *response) {
            NSArray<OBAArrivalAndDepartureV2*> *matchingDepartures = [bookmark matchingArrivalsAndDeparturesForStop:response];
            OBAArrivalAndDepartureV2 *nextDeparture = matchingDepartures.firstObject;
            NSDictionary *replyDictionary = (nextDeparture) ?
            @{@"bestAvailableName":nextDeparture.bestAvailableName,
              @"departureStatus":@(nextDeparture.departureStatus),
              @"minutesUntilBestDeparture":@(nextDeparture.minutesUntilBestDeparture),
              @"stopName":bookmark.stop.name,
              @"stopDirection":bookmark.stop.direction,
              @"name":bookmark.name,
              @"deviationFromSchedule":@(nextDeparture.predictedDepatureTimeDeviationFromScheduleInMinutes)}
            : @{@"name":bookmark.name};
            [self sendMessage:replyDictionary];
        }).catch(^(NSError *error) {
            NSLog(@"Failed to load departure for bookmark: %@", error);
        });
    }
}

@end
