//
//  FlickrHelper.h
//  TopPlaces
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrFetcher.h"

@interface FlickrHelper : FlickrFetcher
#define FLICKR_FETCH @"Flickr Download Session"
#define FLICKR_FETCH_RECENT_RECENT_PHOTOS @"Flickr Download Task to Download Recent Photos"
#define BACKGROUND_FLICKR_FETCH_TIMEOUT 10
#define FLICKR_FETCH_REGION @"Flickr Download Task to Download Region"
#define STARTCELLULAR @"startCellularFlickrFetch"
#define FINISHCELLULAR @"finishedCellularFlickrFetch"

+ (void)loadTopPlacesOnCompletion:(void (^)(NSArray *places, NSError *error))completionHandler;
+ (void)loadTopRegionsOnCompletion:(void (^)(NSArray *photos, NSError *error))completionHandler;
+ (void)loadPhotosInPlace:(NSDictionary *)place
               maxResults:(NSUInteger)results
             onCompletion:(void (^)(NSArray *photos, NSError *error))completionHandler;

+(void)startBackgroundDownloadRecentPhotosOnCompletion:(void (^) (NSArray *photos, void(^whenDne)())) completionHandler
                                allowingCellularAccess:(BOOL)cellular;

+(void)handleEventsForBackgroundURLSession:(NSString *)identifier
                         completionHandler:(void(^)())completionHandler;

typedef void (^RegionCompletionHandler) (NSString *regionName, void(^whenDone)());
+(void) startBackgroundDownloadRegionForPlaceID:(NSString *)placeID
                                   onCompletion:(RegionCompletionHandler) completionHandler;


@property (strong, nonatomic) NSMutableDictionary *regionCompletionHandlers;


@property (strong, nonatomic) NSURLSession *downloadSession;
@property (strong, nonatomic) NSURLSession *cellularDownloadSession;
@property (strong, nonatomic) NSURLSession *currentDownloadSession;
@property (nonatomic) BOOL allowingCellularAccess;

+(BOOL)isCellularDownloadSession;

@property (copy, nonatomic) void (^recentPhotosCompletionHandler)(NSArray *photos, void(^whenDone)());
@property (copy, nonatomic) void (^downloadBackgroundURLSessionCompletionHandler)();

+ (NSString *)countryOfPlace:(NSDictionary *)place;
+ (NSString *)titleOfPlace:(NSDictionary *)place;
+ (NSString *)subtitleOfPlace:(NSDictionary *)place;

+ (NSArray *)sortPlaces:(NSArray *)places;
+ (NSDictionary *)placesByCountries:(NSArray *)places;
+ (NSArray *)countriesFromPlacesByCountry:(NSDictionary *)placesByCountry;

+ (NSString *)titleOfPhoto:(NSDictionary *)photo;
+ (NSString *)subtitleOfPhoto:(NSDictionary *)photo;

+ (NSURL *)URLforPhoto:(NSDictionary *)photo;
+ (NSString *)IDforPhoto:(NSDictionary *)photo;

+ (NSURL *)URLforThumbnail:(NSDictionary *)photo;
+ (NSString *)ownerOfPhoto:(NSDictionary *)photo;
+ (NSString *)placeIDforPhoto:(NSDictionary *)photo;


@end
