//
//  InterfaceController.m
//  OneBusAwayWatch Extension
//
//  Created by Sam Gehman on 7/26/16.
//  Copyright © 2016 OneBusAway. All rights reserved.
//

#import "InterfaceController.h"

@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];

    // Configure interface objects here.
    [self.table setNumberOfRows:1 withRowType:@"TestRow"];
    OBARowController *controller = [self.table rowControllerAtIndex:0];
    [controller.label setText:@"hello"];
}

//////////////////////// ALL OF THIS STUFF NEEDS TO BE GOTTEN FROM WC ///////////////////////////////
- (void)logDepartureDataWithNextDeparture:(OBAArrivalAndDepartureV2*)departure {
    NSLog(@"\n\n\n\n");
    NSLog(@"nextDeparture ::: departureStatus ::: %lu", (unsigned long)[departure departureStatus]);
    NSLog(@"nextDeparture ::: statusText ::: %@", [departure statusText]);
    NSLog(@"nextDeparture ::: predictedDepatureTimeDeviationFromScheduleInMinutes ::: %f", [departure predictedDepatureTimeDeviationFromScheduleInMinutes]);
    NSLog(@"nextDeparture ::: minutesUntilBestDeparture ::: %ld", (long)[departure minutesUntilBestDeparture]);
    NSLog(@"\n\n\n\n");
}

- (void)loadData {
    OBAModelDAO *modelDAO = [OBAApplication sharedApplication].modelDao;
    
//    NSMutableArray *sections = [[NSMutableArray alloc] init];
    
    for (OBABookmarkGroup *group in modelDAO.bookmarkGroups) {
        NSArray *bookmarks = group.bookmarks;
        for (OBABookmarkV2 *bookmark in bookmarks) {
            NSLog(@"\n\n\n\n");
            NSLog(@"bookmark ::: name ::: %@", bookmark.name);
            NSLog(@"\n\n\n\n");
            
            [[OBAApplication sharedApplication].modelService requestStopForID:bookmark.stopId minutesBefore:0 minutesAfter:35].then(^(OBAArrivalsAndDeparturesForStopV2 *response) {
                NSArray<OBAArrivalAndDepartureV2*> *matchingDepartures = [bookmark matchingArrivalsAndDeparturesForStop:response];
                OBAArrivalAndDepartureV2 *nextDeparture = matchingDepartures.firstObject;
                [self logDepartureDataWithNextDeparture:nextDeparture];
//                NSIndexPath *indexPath = [self indexPathForRow:row];
//                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }).catch(^(NSError *error) {
                NSLog(@"Failed to load departure for bookmark: %@", error);
            });
        }
    }
//    
//    OBATableSection *looseBookmarks = [[OBATableSection alloc] initWithTitle:NSLocalizedString(@"Bookmarks", @"") rows:[self tableRowsFromBookmarks:modelDAO.ungroupedBookmarks]];
//    if (looseBookmarks.rows.count > 0) {
//        [sections addObject:looseBookmarks];
//    }
//    
//    self.sections = sections;
//    [self.tableView reloadData];
}

//////////////////////// ALL OF THIS STUFF NEEDS TO BE GOTTEN FROM WC ///////////////////////////////

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



