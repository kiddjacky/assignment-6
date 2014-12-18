//
//  FlickrHelper.m
//  TopPlaces
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrHelper.h"

@interface FlickrHelper() <NSURLSessionDownloadDelegate>
#define FLICKR_FETCH @"Flickr Download Session"
#define FLICKR_FETCH_RECENT_RECENT_PHOTOS @"Flickr Download Task to Download Recent Photos"
#define BACKGROUND_FLICKR_FETCH_TIMEOUT 10
#define FLICKR_FETCH_REGION @"Flickr Download Task to Download Region"
@end

@implementation FlickrHelper

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
}

- (void) URLSession:(NSURLSession *)session
       downloadTask:(NSURLSessionDownloadTask *)downloadTask
       didWriteData:(int64_t)bytesWritten
  totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
}

- (void) downloadTasksMightBeComplete {
    if (self.downloadBackgroundURLSessionCompletionHandler) {
        [self.downloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            NSLog(@"downloadTask %lu", (unsigned long)[downloadTasks count]);
            if(![downloadTasks count]) {
                void (^completionHandler)() = self.downloadBackgroundURLSessionCompletionHandler;
                self.downloadBackgroundURLSessionCompletionHandler = nil;
                NSLog(@"might");
                if(completionHandler) {
                    completionHandler();
                    NSLog(@"finish completion");
                }
            }
        }];
    }
}

-(void) URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH_RECENT_RECENT_PHOTOS]) {
        NSDictionary *flickrPropertyList;
        NSData *flickrJSONData = [NSData dataWithContentsOfURL:location];
        if (flickrJSONData) {
            flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                                 options:0
                                                                   error:NULL];
        }
        NSArray *photos = [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        //NSLog(@"PHOTOS are %@", photos);
        self.recentPhotosCompletionHandler(photos, ^{
            [self downloadTasksMightBeComplete];
             });
    }
    else if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH_REGION]) {
        NSDictionary *flickrPropertyList;
        NSData *flickrJSONData = [NSData dataWithContentsOfURL:location];
        if (flickrJSONData) {
            flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                                 options:0
                                                                   error:NULL];
        }
        NSString *regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:flickrPropertyList];
        RegionCompletionHandler regionCompletionHandler = [self.regionCompletionHandlers[@(downloadTask.taskIdentifier)] copy];
        if(regionCompletionHandler) {
            regionCompletionHandler(regionName, ^{
                [self downloadTasksMightBeComplete];
            });
        }

    }
    NSLog(@"task is %@", downloadTask.taskDescription);
}

-(void) URLSession:(NSURLSession *)session
             task:(NSURLSessionTask *)task
             didCompleteWithError:(NSError *)error
{
    if(error && (session == self.downloadSession) ) {
        NSLog(@"Flickr background download session failed: %@", error.localizedDescription);
        [self downloadTasksMightBeComplete];
    }
}
             

            
             
             
+ (void)loadTopPlacesOnCompletion:(void (^)(NSArray *places, NSError *error))completionHandler
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrHelper URLforTopPlaces]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *places;
                                                    if (!error) {
                                                        places = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                 options:0
                                                                                                   error:&error] valueForKeyPath:FLICKR_RESULTS_PLACES];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        completionHandler(places, error);
                                                    });
                                                }];
    [task resume];
}



+ (void)loadTopRegionsOnCompletion:(void (^)(NSArray *photos, NSError *error))completionHandler
{
    NSURLSessionConfiguration *config =[NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.allowsCellularAccess = NO;
    config.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrHelper URLforRecentGeoreferencedPhotos]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *photos;
                                                    if (!error) {
                                                        photos = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                  options:0
                                                                                                    error:&error] valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        completionHandler(photos, error);
                                                    });
                                                }];
    [task resume];
}

+ (void)loadPhotosInPlace:(NSDictionary *)place
               maxResults:(NSUInteger)results
             onCompletion:(void (^)(NSArray *photos, NSError *error))completionHandler
{
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[FlickrHelper URLforPhotosInPlace:[place valueForKeyPath:FLICKR_PLACE_ID] maxResults:(int)results]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *photos;
                                                    if (!error) {
                                                        photos = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                  options:0
                                                                                                    error:&error] valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        completionHandler(photos, error);
                                                    });
                                                }];
    [task resume];
}





-(NSURLSession *)downloadSession
{
    if(!_downloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_FETCH]
                                                             delegate:self
                                                        delegateQueue:nil];
        });
        NSLog(@"in download session");
    }
    return _downloadSession;
}

+(FlickrHelper *)sharedFlickrHelper
{
    static dispatch_once_t pred = 0;
    __strong static FlickrHelper *_sharedFlickrHelper = nil;
    dispatch_once(&pred, ^{
        _sharedFlickrHelper = [[self alloc] init];
    });
    return _sharedFlickrHelper;
}



+(void)startBackgroundDownloadRecentPhotosOnCompletion:(void (^) (NSArray *photos, void(^whenDne)())) completionHandler
{
    FlickrHelper *fh = [FlickrHelper sharedFlickrHelper];
    [fh.downloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [fh.downloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH_RECENT_RECENT_PHOTOS;
            fh.recentPhotosCompletionHandler = completionHandler;
            [task resume];
            NSLog(@"new task");
        } else {
            NSLog(@"old task");
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

+(void)startBackgroundDownloadRegionForPlaceID:(NSString *)placeID onCompletion:(RegionCompletionHandler)completionHandler {
    FlickrHelper *fh = [FlickrHelper sharedFlickrHelper];
    [fh.downloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        //if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [fh.downloadSession downloadTaskWithURL:[FlickrFetcher URLforInformationAboutPlace:placeID]];
            task.taskDescription = FLICKR_FETCH_REGION;
            [fh.regionCompletionHandlers setObject:[completionHandler copy] forKey:@(task.taskIdentifier)];
            [task resume];
        /*}
        else {
            NSLog(@"download cout is %lu", (unsigned long)[downloadTasks count]);
        }*/
    }];
}

-(NSMutableDictionary *) regionCompletionHandlers
{
    if (!_regionCompletionHandlers) {
        _regionCompletionHandlers = [[NSMutableDictionary alloc] init];
    }
    return _regionCompletionHandlers;
}

+(void)handleEventsForBackgroundURLSession:(NSString *)identifier
                         completionHandler:(void(^)())completionHandler
{
    if ([identifier isEqualToString:FLICKR_FETCH]) {
        FlickrHelper *fh = [FlickrHelper sharedFlickrHelper];
        fh.downloadBackgroundURLSessionCompletionHandler = completionHandler;
    }
}




+ (NSString *)titleOfPlace:(NSDictionary *)place
{
    return [[[place valueForKeyPath:FLICKR_PLACE_NAME]
             componentsSeparatedByString:@", "] firstObject];
}

+ (NSString *)subtitleOfPlace:(NSDictionary *)place
{
    NSArray *nameParts = [[place valueForKeyPath:FLICKR_PLACE_NAME]
                          componentsSeparatedByString:@", "];
    NSRange range;
    range.location = 1;
    range.length = [nameParts count] - 2;
    return [[nameParts subarrayWithRange:range] componentsJoinedByString:@", "];
}

+ (NSString *)countryOfPlace:(NSDictionary *)place
{
    return [[[place valueForKeyPath:FLICKR_PLACE_NAME]
             componentsSeparatedByString:@", "] lastObject];
}

+ (NSArray *)sortPlaces:(NSArray *)places
{
    return [places sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1 = [obj1 valueForKeyPath:FLICKR_PLACE_NAME];
        NSString *name2 = [obj2 valueForKeyPath:FLICKR_PLACE_NAME];
        return [name1 localizedCompare:name2];
    }];
}

+ (NSDictionary *)placesByCountries:(NSArray *)places
{
    NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
    for (NSDictionary *place in places) {
        NSString *country = [FlickrHelper countryOfPlace:place];
        NSMutableArray *placesOfCountry = placesByCountry[country];
        if (!placesOfCountry) {
            placesOfCountry = [NSMutableArray array];
            placesByCountry[country] = placesOfCountry;
        }
        [placesOfCountry addObject:place];
    }
    return placesByCountry;
}

+ (NSArray *)countriesFromPlacesByCountry:(NSDictionary *)placesByCountry
{
    NSArray *countries = [placesByCountry allKeys];
    countries = [countries sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSCaseInsensitiveSearch];
    }];
    return countries;
}

/*
+ (NSArray *)mostPopularRegion:(NSDictionary *)place
{

}
 */

#define FLICKR_UNKNOWN_PHOTO_TITLE @"Unknown"

+ (NSString *)titleOfPhoto:(NSDictionary *)photo
{
    NSString *title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    if ([title length]) return title;
    
    title = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if ([title length]) return title;
    
    return FLICKR_UNKNOWN_PHOTO_TITLE;
}

+ (NSString *)subtitleOfPhoto:(NSDictionary *)photo
{
    NSString *title = [FlickrHelper titleOfPhoto:photo];
    if ([title isEqualToString:FLICKR_UNKNOWN_PHOTO_TITLE]) return @"";
    
    NSString *subtitle = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    if ([title isEqualToString:subtitle]) return @"";
    
    return subtitle;
}

+ (NSURL *)URLforPhoto:(NSDictionary *)photo
{
    return [FlickrHelper URLforPhoto:photo format:FlickrPhotoFormatLarge];
}

+ (NSString *)IDforPhoto:(NSDictionary *)photo
{
    return [photo valueForKeyPath:FLICKR_PHOTO_ID];
}


+(NSString *) placeIDforPhoto:(NSDictionary *)photo
{
    return [photo valueForKey:FLICKR_PHOTO_PLACE_ID];
}

+(NSURL *)URLforThumbnail:(NSDictionary *)photo
{
    return [FlickrHelper URLforPhoto:photo format:FlickrPhotoFormatSquare];
}

+(NSString *)ownerOfPhoto:(NSDictionary *)photo
{
    return [photo valueForKeyPath:FLICKR_PHOTO_OWNER];
}

@end
