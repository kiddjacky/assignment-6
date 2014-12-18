//
//  RecentPhotosTVC.m
//  TopPlaces
//
//  Created by Martin Mandl on 07.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "RecentPhotosTVC.h"
#import "RecentPhotos.h"
#import "PhotosTVC.h"
#import "PhotoDatabaseAvailability.h"

@interface RecentPhotosTVC ()
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation RecentPhotosTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	//self.photos = [RecentPhotos allPhotos];
}



- (void)awakeFromNib
{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      self.managedObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"recent != nil"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"recent.lastView"
                                                              ascending:NO]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
}


@end
