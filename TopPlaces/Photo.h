//
//  Photo.h
//  TopPlaces
//
//  Created by kiddjacky on 11/1/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Recent, Region, Photographer;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) Region *region;
@property (nonatomic, retain) Photographer *photographer;
@property (nonatomic, retain) Recent *recent;

@end
