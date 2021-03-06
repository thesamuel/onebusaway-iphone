//
//  OBAModelPersistenceLayer.h
//  org.onebusaway.iphone
//
//  Created by Aaron Brethorst on 4/3/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@class OBARegionV2;

NS_ASSUME_NONNULL_BEGIN

@protocol OBAModelPersistenceLayer <NSObject>
@property(nonatomic,assign) BOOL hideFutureLocationWarnings;

- (NSArray*) readBookmarks;
- (void) writeBookmarks:(NSArray*)source;

- (NSArray*) readBookmarkGroups;
- (void) writeBookmarkGroups:(NSArray*)source;

- (NSArray*) readMostRecentStops;
- (void) writeMostRecentStops:(NSArray*)source;

- (NSDictionary*) readStopPreferences;
- (void) writeStopPreferences:(NSDictionary*)stopPreferences;

- (CLLocation * _Nullable) readMostRecentLocation;
- (void) writeMostRecentLocation:(CLLocation*)mostRecentLocation;

- (NSSet*) readVisistedSituationIds;
- (void) writeVisistedSituationIds:(NSSet*)situationIds;

- (OBARegionV2 * _Nullable) readOBARegion;
- (void)writeOBARegion:(OBARegionV2*)region;

- (BOOL) readSetRegionAutomatically;
- (void) writeSetRegionAutomatically:(BOOL)setRegionAutomatically;

- (NSString*) readCustomApiUrl;
- (void) writeCustomApiUrl:(NSString*)customApiUrl;

- (NSArray*) readMostRecentCustomApiUrls;
- (void) writeMostRecentCustomApiUrls:(NSArray*)customApiUrls;

@end

NS_ASSUME_NONNULL_END