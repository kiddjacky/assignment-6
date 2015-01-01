//
//  ImageCache.h
//  TopPlaces
//
//  Created by kiddjacky on 12/31/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
+(void)cacheImageData:(NSData *)data forURL:(NSURL *)url;
+(UIImage *)cachedImageForURL:(NSURL *)url;

@end
