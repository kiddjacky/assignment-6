//
//  Region+create.m
//  TopPlaces
//
//  Created by kiddjacky on 11/8/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Region+create.h"
#import "Photographer.h"
#import "FlickrHelper.h"

@implementation Region (create)

+(Region *) regionWithPlaceID:(NSString *)placeID
             withPhotographer:(Photographer *)photographer
    inManagedObjectContext:(NSManagedObjectContext *)context
{
    Region *region = nil;
    
    if ([placeID length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"placeID = %@", placeID];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            //handle errors
        }
        else if (![matches count]) {
            region= [NSEntityDescription insertNewObjectForEntityForName:@"Region"
                                                  inManagedObjectContext:context];
            //region.name = [FlickrHelp];
            region.num_photographers = [NSNumber numberWithInt:1];
            region.num_photos = [NSNumber numberWithInt:1];
            region.placeID = placeID;
            [region addPhotographersObject:photographer];
            NSLog(@"%@", region.placeID);
        }
        else {
            region = [matches firstObject];
            int num_photos = [region.num_photos intValue];
            region.num_photos = [NSNumber numberWithInt:(num_photos + 1)];
            
            if(![region.photographers member:photographer]) {
                [region addPhotographersObject:photographer];
                int num_photographers = [region.num_photographers intValue];
                region.num_photographers = [NSNumber numberWithInt:(num_photographers + 1)];
            }
            NSLog(@"%@ already in database", region.placeID);
            
        }
    }
    
    return region;
}


+(void) loadRegionNamesFromFlickrIntoManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"name.length=%@", nil];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || [matches count] > 1) {
        //handle error
    }
    else {
        BOOL saveDocument = NO;
        
        for (Region *match in matches) {
            if ([match isEqual:[matches lastObject]]) {
                saveDocument = YES;
            }
            
            //FlickrHelper startBackgroundDownloadRegionForPlaceID:match.placeID
        }
    }
}



@end
