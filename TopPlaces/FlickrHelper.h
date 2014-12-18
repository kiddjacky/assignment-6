//
//  FlickrHelper.h
//  TopPlaces
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrFetcher.h"

@interface FlickrHelper : FlickrFetcher

+ (void)loadTopPlacesOnCompletion:(void (^)(NSArray *places, NSError *error))completionHandler;
+ (void)loadTopRegionsOnCompletion:(void (^)(NSArray *photos, NSError *error))completionHandler;
+ (void)loadPhotosInPlace:(NSDictionary *)place
               maxResults:(NSUInteger)results
             onCompletion:(void (^)(NSArray *photos, NSError *error))completionHandler;

+(void)startBackgroundDownloadRecentPhotosOnCompletion:(void (^) (NSArray *photos, void(^whenDne)())) completionHandler;
+(void)handleEventsForBackgroundURLSession:(NSString *)identifier
                         completionHandler:(void(^)())completionHandler;

typedef void (^RegionCompletionHandler) (NSString *regionName, void(^whenDone)());
+(void) startBackgroundDownloadRegionForPlaceID:(NSString *)placeID
                                   onCompletion:(RegionCompletionHandler) completionHandler;


@property (strong, nonatomic) NSMutableDictionary *regionCompletionHandlers;


@property (strong, nonatomic) NSURLSession *downloadSession;

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
