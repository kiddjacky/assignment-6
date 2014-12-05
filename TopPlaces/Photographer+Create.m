//
//  Photographer+Create.m
//  TopPlaces
//
//  Created by kiddjacky on 11/4/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "Photographer+Create.h"

@implementation Photographer (Create)

+(Photographer *)photographerWithName:(NSString *)name
               inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || error || ([matches count] > 1)) {
            //handle errors
        }
        else if (![matches count]) {
            photographer = [NSEntityDescription insertNewObjectForEntityForName:@"Photographer" inManagedObjectContext:context];
            photographer.name = name;
            NSLog(@"%@", photographer.name);
        }
        else {
            photographer = [matches firstObject];
            NSLog(@"%@ already in database", photographer.name);
        }
    }
    
    return photographer;
}

@end
