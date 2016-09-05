#import "OBAModelDAO.h"
#import "OBAModelFactory.h"
#import "OBAJsonDataSource.h"
#import "OBALocationManager.h"

#import "OBAReferencesV2.h"
#import "OBAStopV2.h"
#import "OBAPlacemark.h"
#import "OBATripInstanceRef.h"
#import "OBAArrivalAndDepartureInstanceRef.h"
#import "OBAReportProblemWithStopV2.h"
#import "OBAReportProblemWithTripV2.h"
#import <PromiseKit/PromiseKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const OBAAgenciesWithCoverageAPIPath;

@protocol OBAModelServiceRequest <NSObject>
- (void)cancel;
@end

/**
 * This protocol mimics the functionality of UIApplication.  It is placed here to get around Extension only API limitation.
 */
@protocol OBABackgroundTaskExecutor <NSObject>
- (UIBackgroundTaskIdentifier) beginBackgroundTaskWithExpirationHandler:(void(^)(void))handler;
- (UIBackgroundTaskIdentifier) endBackgroundTask:(UIBackgroundTaskIdentifier) task;
@end

@interface OBAModelService : NSObject
@property (nonatomic, strong) OBAReferencesV2 *references;
@property (nonatomic, strong) OBAModelDAO *modelDao;
@property (nonatomic, strong) OBAModelFactory *modelFactory;
@property (nonatomic, strong) OBAJsonDataSource *obaJsonDataSource;
@property (nonatomic, strong) OBAJsonDataSource *obaRegionJsonDataSource;
@property (nonatomic, strong) OBAJsonDataSource *googleMapsJsonDataSource;
@property (nonatomic, strong) OBAJsonDataSource *googlePlacesJsonDataSource;
@property (nonatomic, strong) OBALocationManager *locationManager;

/**
 Convenience method for constructing an entire
 model service/factory/references stack.
 */
+ (instancetype)modelServiceWithBaseURL:(NSURL*)URL;

/**
 * Registers a background executor to be used by all services.  This method should not be used by extensions.
 */
+(void) addBackgroundExecutor:(NSObject<OBABackgroundTaskExecutor>*) executor;

- (AnyPromise*)requestStopForID:(NSString*)stopID minutesBefore:(NSUInteger)minutesBefore minutesAfter:(NSUInteger)minutesAfter;

/**
 Trip details for the specified OBATripInstanceRef

 @param tripInstance The trip instance reference

 @return An instance of OBATripDetailsV2
 */
- (AnyPromise*)requestTripDetailsForTripInstance:(OBATripInstanceRef *)tripInstance;

/**
 Retrieves an up-to-date OBAArrivalAndDepartureV2 object.

 @param instanceRef The OBAArrivalAndDepartureInstanceRef whose parent object we're updating (I think? The model architecture is still confusing to me.)

 @return A promise that resolves to a OBAArrivalAndDepartureV2 object.
 */
- (AnyPromise*)requestArrivalAndDeparture:(OBAArrivalAndDepartureInstanceRef*)instanceRef;

/**
 Retrieves the current server time as an NSNumber representing the number of milliseconds since January 1, 1970.

 @return A promise that resolves to an NSNumber object.
 */
- (AnyPromise*)requestCurrentTime;

/**
 Retrieves all available OBA regions, including experimental and inactive regions. Returns an array of OBARegionV2 objects.
 *
 *  @return A promise that resolves to NSArray<OBARegionV2*>*.
 */
- (AnyPromise*)requestRegions;

/**
 Retrieves all available OBA regions, including experimental and inactive regions. Returns an array of OBARegionV2 objects.
 *
 *  @return A promise that resolves to NSArray<OBAAgencyWithCoverageV2*>*.
 */
- (AnyPromise*)requestAgenciesWithCoverage;

/**
 *  Makes an asynchronous request to fetch the current server time.
 *
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestCurrentTimeWithCompletionBlock:(OBADataSourceCompletion)completion;

/**
 *  Makes an asynchronous request to fetch a stop object.
 *
 *  @param stopId     The string identifier of the stop to be fetched
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestStopForId:(NSString *)stopId
                               completionBlock:(OBADataSourceCompletion)completion;
/**
 *  Makes an asynchronous request to fetch a stop object that is also inflated with additional data for arrival and departure time
 *
 *  @param stopId        The string identifier of the stop to be fetched
 *  @param minutesBefore The lower bound of time for which arrivals are returned
 *  @param minutesAfter  The upper bound of time for which arrivals are returned
 *  @param completion    The block to be called once the request completes, this is always executed on the main thread.
 *  @param progress      The block to be called with progress updates, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestStopWithArrivalsAndDeparturesForId:(NSString *)stopId
                                                      withMinutesBefore:(NSUInteger)minutesBefore
                                                       withMinutesAfter:(NSUInteger)minutesAfter
                                                        completionBlock:(OBADataSourceCompletion)completion
                                                          progressBlock:(nullable OBADataSourceProgress)progress;
/**
 *  Makes an asynchronous request for a set of stops within a given region
 *
 *  @param region     Region for which the stops are returned
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestStopsForRegion:(MKCoordinateRegion)region
                                    completionBlock:(OBADataSourceCompletion)completion;

/**
 *  Makes an asynchronous request to get a set of stops for a given query, bounded by a region
 *
 *  @param stopQuery  A "stopCode" represented by a string
 *  @param region     A region
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestStopsForQuery:(NSString *)stopQuery
                                        withRegion:(nullable CLCircularRegion *)region
                                   completionBlock:(OBADataSourceCompletion)completion;
/**
 *  Makes an asynchronous request to fetch a set of stops that belong to a particular route.
 *
 *  @param routeId    Identifier of a route for which the stops need to be fetched
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestStopsForRoute:(NSString *)routeId
                                   completionBlock:(OBADataSourceCompletion)completion;
/**
 *  Makes an asynchronous request to fetch a set of stops near a placemark
 *
 *  @param placemark  A placemark defined by @see OBAPlacemark object
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestStopsForPlacemark:(OBAPlacemark *)placemark
                                       completionBlock:(OBADataSourceCompletion)completion;

/**
 *  Makes an asynchronous request to fetch a set of routes
 *
 *  @param routeQuery Query to identify a route
 *  @param region     The region by which the search is going to be limited by
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestRoutesForQuery:(NSString *)routeQuery
                                         withRegion:(nullable CLCircularRegion *)region
                                    completionBlock:(OBADataSourceCompletion)completion;
/**
 *  Makes an asynchronous request to fetch a set of placemarks based on address string
 *
 *  @param address    The address to be used to search for placemarks
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)placemarksForAddress:(NSString *)address
                                   completionBlock:(OBADataSourceCompletion)completion;

/**
 *  Makes an asynchronous request to fetch all available OBA regions, including experimental and inactive
 *
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestRegions:(OBADataSourceCompletion)completion;

/**
 *  Makes an asynchronous request to fetch all available agencies.
 *
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestAgenciesWithCoverage:(OBADataSourceCompletion)completion;

/**
 *  Makes an asynchronous request to fetch arrival and departure times for a particular stop
 *
 *  @param instance   An instance of a stop
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestArrivalAndDepartureForStop:(OBAArrivalAndDepartureInstanceRef *)instance
                                                completionBlock:(OBADataSourceCompletion)completion;
/**
 *  Makes an asynchronous request to fetch trip details
 *
 *  @param tripInstance An intance of a trip
 *  @param completion   The block to be called once the request completes, this is always executed on the main thread.
 *  @param progress     The block to be called with progress updates, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestTripDetailsForTripInstance:(OBATripInstanceRef *)tripInstance
                                                completionBlock:(OBADataSourceCompletion)completion
                                                  progressBlock:(nullable OBADataSourceProgress)progress;
/**
 *  Makes an asynchronous request to fetch a vehicle definition based on id
 *
 *  @param vehileId  The identifier of the vehicle to be fetched
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestVehicleForId:(NSString *)vehicleId
                                  completionBlock:(OBADataSourceCompletion)completion;
/**
 *  Makes an asynchronous request to fetch a shape
 *
 *  @param shapeId    Identifier of a shape
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)requestShapeForId:(NSString *)shapeId
                                completionBlock:(OBADataSourceCompletion)completion;
/**
 *  Makes an asynchronous request to report a problem with a stop
 *
 *  @param problem    Problem definition to be used for submission
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)reportProblemWithStop:(OBAReportProblemWithStopV2 *)problem
                                    completionBlock:(OBADataSourceCompletion)completion;
/**
 *  Makes an asynchronous request to report a problem with a trip
 *
 *  @param problem    Problem definition to be used for submission
 *  @param completion The block to be called once the request completes, this is always executed on the main thread.
 *
 *  @return The OBAModelServiceRequest object that allows request cancellation
 */
- (id<OBAModelServiceRequest>)reportProblemWithTrip:(OBAReportProblemWithTripV2 *)problem
                                    completionBlock:(OBADataSourceCompletion)completion;

@end

NS_ASSUME_NONNULL_END