//
//  Photographer+Create.h
//  TopPlaces
//
//  Created by kiddjacky on 11/4/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+(Photographer *)photographerWithName:(NSString *)name
               inManagedObjectContext:(NSManagedObjectContext *)context;
@end
