//
//  OBAStopViewController.h
//  org.onebusaway.iphone
//
//  Created by Aaron Brethorst on 2/20/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "OBAStaticTableViewController.h"
#import "OBANavigationTargetAware.h"

@class OBAModelDAO;

NS_ASSUME_NONNULL_BEGIN

@interface OBAStopViewController : OBAStaticTableViewController<OBANavigationTargetAware>
@property(nonatomic,strong) OBAModelDAO *modelDAO;
@property(nonatomic,copy,readonly) NSString *stopID;
@property(nonatomic,assign) NSUInteger minutesBefore;
@property(nonatomic,assign) NSUInteger minutesAfter;

- (instancetype)initWithStopID:(NSString*)stopID NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END