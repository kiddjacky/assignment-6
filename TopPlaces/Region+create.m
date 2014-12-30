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
#import "DocumentHelper.h"

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
    request.predicate = [NSPredicate predicateWithFormat:@"name.length = %@", nil];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ![matches count] || error) {
        //handle error
        if (error) {
        NSLog(@"in region error state");
        }
        if (![matches count]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FINISHCELLULAR
                                                                object:self];
            NSLog(@"no name is empty");
        }
        else {
            NSLog(@"match count more than 1");
        }
    }
    else {
        BOOL saveDocument = NO;
        NSLog(@"match count is %lu", [matches count]);
        for (Region *match in matches) {
            if ([match isEqual:[matches lastObject]]) {
                saveDocument = YES;
            }
            
            [FlickrHelper startBackgroundDownloadRegionForPlaceID:match.placeID
                                                     onCompletion:^(NSString *regionName, void(^whenDone)()) {
                                                         NSLog(@"start download region");
                [DocumentHelper useDocumentWithOperation:^(UIManagedDocument *document, BOOL success)  {
                    if (success) {
                        [document.managedObjectContext performBlock:^{
                            Region *region = nil;
                            NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
                            request.predicate = [NSPredicate predicateWithFormat:@"placeID = %@", match.placeID];
                            //NSLog(@"match is %@, region name is %@", match, regionName);
                            NSError *error;
                            NSArray *IDmatches = [document.managedObjectContext executeFetchRequest:request error:&error];
                            
                            if (!IDmatches || ([IDmatches count] !=1)) {
                                //handle error
                            }
                            else { //ID match and it is the only ID
                                region = [IDmatches lastObject];
                                request.predicate = [NSPredicate predicateWithFormat:@"name = %@", regionName];
                                NSArray *nameMatches = [document.managedObjectContext executeFetchRequest:request error:&error];
                                if (!nameMatches) {
                                    //handle error
                                }
                                else if (![nameMatches count]) {
                                    //NSLog(@"region name is %@",regionName);
                                    region.name = regionName;
                                } else {
                                    //NSLog(@"%@ with existing other places", regionName);
                                    region.name = regionName;
                                    for (Region *match in nameMatches) {
                                        region.photos = [region.photos setByAddingObjectsFromSet:match.photos];
                                        region.num_photos = @([region.photos count]);
                                        region.photographers = [region.photographers setByAddingObjectsFromSet:match.photographers];
                                        region.num_photographers = @([region.photographers count]);
                                        [document.managedObjectContext deleteObject:match];
                                    }
                                }
                                if (saveDocument) {
                                    [document saveToURL:document.fileURL
                                       forSaveOperation:UIDocumentSaveForOverwriting
                                      completionHandler:nil];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:FINISHCELLULAR object:self];
                                    //NSLog(@"save regions");
                                }
                            }
                            if (whenDone) whenDone();
                         }];
                    } else {
                        if (whenDone) whenDone();
                    }
                }];
            }];
        }
    }
}



@end
