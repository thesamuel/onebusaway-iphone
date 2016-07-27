//
//  InterfaceController.m
//  OneBusAwayWatch Extension
//
//  Created by Sam Gehman on 7/26/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "InterfaceController.h"

//#import "OBABookmarksViewController.h"
#import "OBAApplication.h"
#import "OBABookmarkGroup.h"
//#import "OBAStopViewController.h"
//#import "OBAEditStopBookmarkViewController.h"
//#import <OBAKit/OBAModelDAO.h>
//#import <OBAKit/OBAArrivalAndDepartureV2.h>
//#import "OBABookmarkedRouteRow.h"
//#import "OBAArrivalAndDepartureSectionBuilder.h"
//#import "OBAClassicDepartureRow.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [self.table setNumberOfRows:1 withRowType:@"TestRow"];
    OBARowController *controller = [self.table rowControllerAtIndex:0];
    [controller.label setText:@"hello"];
    [OBAApplication sharedApplication].delegate;
}





- (void)loadData {
    OBAModelDAO *modelDAO = [OBAApplication sharedApplication].modelDao;
    
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    
    for (OBABookmarkGroup *group in modelDAO.bookmarkGroups) {
        NSArray *bookmarks = group.bookmarks;
        //for each
        //bookmarks
        
        
        
        
        /**
         Walks through a series of possible options for giving this arrival and departure a user-sensible name.
         
         @return A string (hopefully) suitable for presenting to the user.
         */
        - (NSString*)bestAvailableName;
        
        - (OBADepartureStatus)departureStatus;
        
        - (NSString*)statusText;
        
        /**
         How far off is this vehicle from its predicted, scheduled time?
         
         @return `NaN` when real time data is unavailable. Negative is early, positive is delayed.
         */
        - (double)predictedDepatureTimeDeviationFromScheduleInMinutes;
        
        /**
         How far away are we right now from the best departure time available to us? Uses real time data when available, and scheduled data otherwise.
         
         @return The number of minutes until departure, suitable to display to a user.
         */
        - (NSInteger)minutesUntilBestDeparture;
        
        
        
        
        // departure
        [self.modelService requestStopForID:bookmark.stopId minutesBefore:0 minutesAfter:35].then(^(OBAArrivalsAndDeparturesForStopV2 *response) {
            NSArray<OBAArrivalAndDepartureV2*> *matchingDepartures = [bookmark matchingArrivalsAndDeparturesForStop:response];
            ((OBABookmarkedRouteRow*)row).nextDeparture = matchingDepartures.firstObject;
            NSIndexPath *indexPath = [self indexPathForRow:row];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }).catch(^(NSError *error) {
            NSLog(@"Failed to load departure for bookmark: %@", error);
        });
    }
    
    
    
    
    
    
    
    
    
    
    
    
    OBATableSection *looseBookmarks = [[OBATableSection alloc] initWithTitle:NSLocalizedString(@"Bookmarks", @"") rows:[self tableRowsFromBookmarks:modelDAO.ungroupedBookmarks]];
    if (looseBookmarks.rows.count > 0) {
        [sections addObject:looseBookmarks];
    }
    
    self.sections = sections;
    [self.tableView reloadData];
}


#pragma mark - Private

- (NSArray<OBATableRow*>*)tableRowsFromBookmarks:(NSArray<OBABookmarkV2*>*)bookmarks {
    NSMutableArray *rows = [NSMutableArray array];
    
    for (OBABookmarkV2 *bm in bookmarks) {
        
        if (bm.stopId.length == 0) {
            // bookmark was somehow corrupted. Skip it and continue on.
            NSLog(@"Corrupted bookmark: %@", bm);
            continue;
        }
        
        if (bm.regionIdentifier != NSNotFound && bm.regionIdentifier != [self currentRegion].identifier) {
            // We are special-casing bookmarks that don't have a region set on them, as there's no way to know
            // for sure which region they belong to. However, if this bookmark has a valid regionIdentifier and
            // the current region's identifier doesn't match the bookmark, then this bookmark belongs to a
            // different region. Skip it.
            continue;
        }
        
        OBABaseRow *row = [self tableRowForBookmark:bm];
        
        [rows addObject:row];
    }
    
    return rows;
}

#pragma mark - Row Builders

/**
 This is the entry point to all of the row builders.
 */
- (OBABaseRow*)tableRowForBookmark:(OBABookmarkV2*)bookmark {
    if (bookmark.bookmarkVersion > OBABookmarkVersion252) {
        // return data
        //return [self rowForBookmarkVersion260:bookmark];
        
        
        
        OBABookmarkV2 *bookmark = [self rowForBookmarkVersion252:bookmark].bookmark;
        OBAArrivalAndDepartureV2 *nextDeparture = [self rowForBookmarkVersion252:bookmark].nextDeparture;
        
        
        bookmark
        //@property(nonatomic,copy) NSString *name;
        //@property(nonatomic,copy) NSString *routeShortName;
        //@property(nonatomic,copy) NSString *stopId;
        //@property(nonatomic,copy) NSString *tripHeadsign;
        //@property(nonatomic,copy) NSString *routeID;
        
        nextdeparture
        /**
         This string is composed of this object's routeId, tripHeadsign, and bestAvailableName.
         It is designed to offer a unique key for determining bookmark existence during the process of creating one.
         */
        - (NSString*)bookmarkKey;
        

        

        
        
        
        
        
        
        
        
        
    }
    else {
        // return data
        //return [self rowForBookmarkVersion252:bookmark];
        NSString *titleString = [self rowForBookmarkVersion260:bookmark].title;
    }
}

//OBATableRow interface
//@property(nonatomic,copy) NSString *title; :::::::::::::::::::: use this
//@property(nonatomic,copy) NSString *subtitle;
//@property(nonatomic,assign) UITableViewCellStyle style;
//@property(nonatomic,strong) UIImage *image;
//@property(nonatomic,assign) NSTextAlignment textAlignment;
- (OBABaseRow*)rowForBookmarkVersion252:(OBABookmarkV2*)bm {
    OBATableRow *row = [[OBATableRow alloc] initWithTitle:bm.name action:^{
        OBAStopViewController *controller = [[OBAStopViewController alloc] initWithStopID:bm.stopId]; //::::::::: goes to stop
        [self.navigationController pushViewController:controller animated:YES];
    }];
    
    [self performCommonBookmarkRowConfiguration:row forBookmark:bm];
    
    return row;
}


// OBABookmarkedRouteRow interface
//@interface OBABookmarkedRouteRow : OBABaseRow
//@property(nonatomic,copy) OBABookmarkV2 *bookmark;
//@property(nonatomic,strong) OBAArrivalAndDepartureV2 *nextDeparture;


// OBABookmarkV2 interface
//@property(nonatomic,copy) NSString *name; ::::::::::::::::::::::::
//@property(nonatomic,copy) NSString *routeShortName;::::::::::::::::::::::::
//@property(nonatomic,copy) NSString *stopId;::::::::::::::::::::::::
//@property(nonatomic,copy) NSString *tripHeadsign;::::::::::::::::::::::::
//@property(nonatomic,copy) NSString *routeID;::::::::::::::::::::::::
//@property(nonatomic,copy,nullable) OBAStopV2 *stop;
//@property(nonatomic,strong,nullable) OBABookmarkGroup *group;
//@property(nonatomic,assign) NSInteger regionIdentifier;
//@property(nonatomic,assign,readonly) OBARouteType routeType; ::::::::::::::::::::::::
        //OBARouteTypeLightRail = 0,
        //OBARouteTypeMetro = 1,
        //OBARouteTypeTrain = 2,
        //OBARouteTypeBus = 3,
        //OBARouteTypeFerry = 4,
        //OBARouteTypeUnknown = 999
//@property(nonatomic,assign) NSUInteger sortOrder;
//@property(nonatomic,assign) OBABookmarkVersion bookmarkVersion;

//OBAArrivalAndDepartureV2 stuff
//@property(nonatomic,copy) NSString *routeId;::::::::::::::::::::::::
//@property(nonatomic,weak,readonly) OBARouteV2 * route;
//@property(nonatomic,copy) NSString *routeShortName;::::::::::::::::::::::::
//
//@property(nonatomic,copy) NSString * tripId;::::::::::::::::::::::::
//@property(nonatomic,weak,readonly) OBATripV2 * trip;
//@property(nonatomic,copy,nullable) NSString * tripHeadsign;
//@property(nonatomic,assign) long long serviceDate;
//
//@property(nonatomic,weak,readonly) OBAArrivalAndDepartureInstanceRef * instance;
//@property(nonatomic,weak,readonly) OBATripInstanceRef * tripInstance;
//
//@property(nonatomic,copy) NSString * stopId;
//@property(nonatomic,weak,readonly) OBAStopV2 * stop;
//@property(nonatomic,assign) NSInteger stopSequence;
//
//@property(nonatomic,strong) OBATripStatusV2 * tripStatus;
//
//@property(nonatomic,strong) OBAFrequencyV2 * frequency;
//
//@property(nonatomic,assign) BOOL predicted;
//
//@property(nonatomic,assign) long long scheduledArrivalTime;
//@property(nonatomic,assign) long long predictedArrivalTime;
//@property(nonatomic,assign,readonly) long long bestArrivalTime;
//
//@property(nonatomic,assign) long long scheduledDepartureTime;
//@property(nonatomic,assign) long long predictedDepartureTime;
//@property(nonatomic,assign,readonly) long long bestDepartureTime;
//
//@property(nonatomic,assign) double distanceFromStop;
//@property(nonatomic,assign) NSInteger numberOfStopsAway;

- (OBABaseRow*)rowForBookmarkVersion260:(OBABookmarkV2*)bookmark {
    OBABookmarkedRouteRow *row = [[OBABookmarkedRouteRow alloc] initWithAction:^{
        OBAStopViewController *controller = [[OBAStopViewController alloc] initWithStopID:bookmark.stopId];
        [self.navigationController pushViewController:controller animated:YES];
    }];
    row.bookmark = bookmark;
    
    [self.modelService requestStopForID:bookmark.stopId minutesBefore:0 minutesAfter:35].then(^(OBAArrivalsAndDeparturesForStopV2 *response) {
        NSArray<OBAArrivalAndDepartureV2*> *matchingDepartures = [bookmark matchingArrivalsAndDeparturesForStop:response];
        ((OBABookmarkedRouteRow*)row).nextDeparture = matchingDepartures.firstObject;
        NSIndexPath *indexPath = [self indexPathForRow:row];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }).catch(^(NSError *error) {
        NSLog(@"Failed to load departure for bookmark: %@", error);
    });
    
    [self performCommonBookmarkRowConfiguration:row forBookmark:bookmark];
    
    return row;
}

- (void)performCommonBookmarkRowConfiguration:(OBABaseRow*)row forBookmark:(OBABookmarkV2*)bookmark {
    row.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [row setEditAction:^{
        OBAEditStopBookmarkViewController *editor = [[OBAEditStopBookmarkViewController alloc] initWithBookmark:bookmark];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editor];
        [self presentViewController:nav animated:YES completion:nil];
    }];
    
    [row setDeleteModel:^{
        [[OBAApplication sharedApplication].modelDao removeBookmark:bookmark];
    }];
}













- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



