//
//  Photo+annotation.m
//  TopPlaces
//
//  Created by kiddjacky on 1/1/15.
//  Copyright (c) 2015 m2m server software gmbh. All rights reserved.
//

#import "Photo+annotation.h"

@implementation Photo (annotation)

-(CLLocationCoordinate2D) coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.latitude doubleValue];
    coordinate.longitude = [self.longtitude doubleValue];
    return coordinate;
}

@end
