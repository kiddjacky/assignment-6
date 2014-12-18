//
//  Recent.h
//  TopPlaces
//
//  Created by kiddjacky on 11/1/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Recent : NSManagedObject

@property (nonatomic, retain) NSDate * lastView;
@property (nonatomic, retain) Photo *photo;
+(Recent *) recentPhoto:(Photo *)photo;
@end
