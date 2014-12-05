//
//  Region.h
//  TopPlaces
//
//  Created by kiddjacky on 11/1/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Photographer;

@interface Region : NSManagedObject

@property (nonatomic, retain) NSNumber * num_photos;
@property (nonatomic, retain) NSNumber * num_photographers;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * placeID;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *photographers;
@end

@interface Region (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addPhotographersObject:(Photographer *)value;
- (void)removePhotographersObject:(Photographer *)value;
- (void)addPhotographer:(NSSet *)values;
- (void)removePhotographer:(NSSet *)values;

@end
