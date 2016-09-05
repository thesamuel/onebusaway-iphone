//
//  OBARegionHelper.h
//  org.onebusaway.iphone
//
//  Created by Sebastian Kießling on 11.08.13.
//  Copyright (c) 2013 OneBusAway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBAModelService.h"
#import "OBARegionV2.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const OBARegionDidUpdateNotification;

@class OBARegionHelper;
@protocol OBARegionHelperDelegate <NSObject>
- (void)regionHelperShowRegionListController:(OBARegionHelper*)regionHelper;
@end

@interface OBARegionHelper : NSObject <OBALocationManagerDelegate>
@property(nonatomic,weak) id<OBARegionHelperDelegate> delegate;
- (void)updateNearestRegion;
- (void)updateRegion;
@end

NS_ASSUME_NONNULL_END