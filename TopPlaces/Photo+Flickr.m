//
//  Photo+Flickr.m
//  TopPlaces
//
//  Created by kiddjacky on 11/2/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"
#import "Region+create.h"
#import "FlickrHelper.h"
#import "Recent.h"

@implementation Photo (Flickr)

+ (Photo *) photoWithFlickrInfo:(NSDictionary *)photoDictionary
         inManagedObjectContext:(NSManagedObjectContext *) context
{
    Photo *photo = nil;
    
    NSString *unique = photoDictionary[FLICKR_PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1))
    {
        //handle error
    }
    else if ([matches count]) {
        photo = [matches firstObject];
        NSLog(@"%@ already in database", photo.title);
    }
    else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = unique;
        photo.created = [NSDate date];
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.imageURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.thumbnailURL = [[FlickrHelper URLforThumbnail:photoDictionary] absoluteString];
        
        //create photographer relationship
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.photographer = [Photographer photographerWithName:photographerName inManagedObjectContext:context];
        
        
        //create region relationship
        photo.region = [Region regionWithPlaceID:[FlickrHelper placeIDforPhoto:photoDictionary] withPhotographer:photo.photographer inManagedObjectContext:context];
        NSLog(@"%@", photo.title);
    }
    
    return photo;
    
}

+(void) loadPhotosFromFlickrArray:(NSArray *)photos
         intoManagedObjectContext:(NSManagedObjectContext *) context
{
    for (NSDictionary *photo in photos) {
        [self photoWithFlickrInfo:photo inManagedObjectContext:context];
    }
    NSLog(@"load region name");
    [Region loadRegionNamesFromFlickrIntoManagedObjectContext:context];
}


#define TIMETOREMOVEOLDPHOTOS 60*60*24*7
+(void) removeOldPhotosFromManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"created < %@", [NSDate dateWithTimeIntervalSinceNow:-TIMETOREMOVEOLDPHOTOS]];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || error) {
        //handle error
    } else if (![matches count]) {
        //nothing to do
    } else {
        for (Photo *photo in matches) {
            [photo remove];
        }
        [context save:nil];
    }
    
}

-(void) remove {
    //remove photographer
    if ([self.photographer.photos count] == 1) {
        [self.managedObjectContext deleteObject:self.photographer];
    }
    //remove regions
    if ([self.region.photos count] == 1) {
        [self.managedObjectContext deleteObject:self.region];
    } else { //else deduct region, what happen to region.photographers? handle in first if statement
        self.region.num_photographers = @([self.region.photographers count]);
        self.region.num_photos = @([self.region.photos count]-1);
    }
    if (self.recent) {
        [self.managedObjectContext deleteObject:self.recent];
    }
    [self.managedObjectContext deleteObject:self];
}







@end
