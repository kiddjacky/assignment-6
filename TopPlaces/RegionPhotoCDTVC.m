//
//  RegionPhotoCDTVC.m
//  TopPlaces
//
//  Created by kiddjacky on 12/14/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "RegionPhotoCDTVC.h"
#import "PhotosTVC.h"
#import "ImageVC.h"
#import "Recent.h"

@implementation RegionPhotoCDTVC

-(void)setRegion:(Region *)region
{
    _region = region;
    self.title = region.name;
    [self setupFetchedResultsController];
}

-(void)setupFetchedResultsController
{
    NSManagedObjectContext *context = self.region.managedObjectContext;
    if (context) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"region = %@", self.region];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedStandardCompare:)]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    }
    else {
        self.fetchedResultsController = nil;
    }
}


#pragma - Navigation


- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifer
                fromIndexPath:(NSIndexPath *)indexPath
{
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [Recent recentPhoto:photo];
    
    [super prepareViewController:vc
                        forSegue:segueIdentifer
                   fromIndexPath:indexPath];
}



@end
