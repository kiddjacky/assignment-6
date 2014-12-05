//
//  Region+create.h
//  TopPlaces
//
//  Created by kiddjacky on 11/8/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Region.h"

@interface Region (create)

+(Region *) regionWithPlaceID:(NSString *)placeID
             withPhotographer:(Photographer *)photographer
       inManagedObjectContext:(NSManagedObjectContext *)context;

+(void) loadRegionNamesFromFlickrIntoManagedObjectContext:(NSManagedObjectContext *)context;

@end
