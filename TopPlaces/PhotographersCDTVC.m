//
//  PhotographersCDTVC.m
//  TopPlaces
//
//  Created by kiddjacky on 11/4/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "PhotographersCDTVC.h"
#import "Photographer.h"

@interface PhotographersCDTVC ()

@end

@implementation PhotographersCDTVC

-(void) setManageObjectContext:(NSManagedObjectContext *)manageObjectContext
{
    _manageObjectContext = manageObjectContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)]];
                                
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:manageObjectContext sectionNameKeyPath:nil cacheName:nil];
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Photographer Cell"];
    
    Photographer *photographer = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photographer.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu photos", (unsigned long)[photographer.photos count]];
      
    return cell;
}

@end
