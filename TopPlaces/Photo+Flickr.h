//
//  Photo+Flickr.h
//  TopPlaces
//
//  Created by kiddjacky on 11/2/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+ (Photo *) photoWithFlickrInfo:(NSDictionary *)photoDictionary
         inManagedObjectContext:(NSManagedObjectContext *) context;

+(void) loadPhotosFromFlickrArray:(NSArray *)photos
         intoManagedObjectContext:(NSManagedObjectContext *) context;

@end
