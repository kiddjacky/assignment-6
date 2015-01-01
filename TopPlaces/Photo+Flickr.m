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

    //remove regions
    if ([self.region.photos count] == 1) {
        //NSLog(@"remove region %@", self.region);
        [self.managedObjectContext deleteObject:self.region];
    } else { //else deduct region, what happen to region.photographers? handle in first if statement
        if (!self.region) {
            NSLog(@"photo region is null %@",self);
        } else {
        if ([Photo num_photo_of_photographer:self.photographer in_region:self.region] == 1) {
            //NSLog(@"remove region photographer %@", self.photographer);
            self.region.num_photographers = @([self.region.num_photographers intValue] -1);
            [self.region removePhotographersObject:self.photographer];
        }
        self.region.num_photos = @([self.region.num_photos intValue]-1);
        //NSLog(@"remove photo in region %@, now regions photo count is %@, photographers count is %@", self.region.name, self.region.num_photos, self.region.num_photographers);
                        [self.region removePhotosObject:self];
        }
    }
    //remove photographer
    if ([self.photographer.photos count] == 1) {
        //NSLog(@"remove photographer %@", self.photographer);
        [self.managedObjectContext deleteObject:self.photographer];
    }
    if (self.recent) {
        //NSLog(@"remove recent photo %@", self.recent);
        [self.managedObjectContext deleteObject:self.recent];
    }
    [self.managedObjectContext deleteObject:self];
}



+(NSInteger) num_photo_of_photographer:(Photographer *)photographer in_region:(Region *)region
{
    NSInteger result = 0;
    for (Photo *photo in region.photos) {
        if ([photo.photographer isEqual:photographer]) {
            result++;
        }
    }
    return result;
}



@end
