//
//  FlickrHelper.m
//  TopPlaces
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "FlickrHelper.h"

@implementation FlickrHelper

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

@end
