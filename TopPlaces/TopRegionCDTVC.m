//
//  TopRegionCDTVC.m
//  TopPlaces
//
//  Created by kiddjacky on 12/7/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "TopRegionCDTVC.h"
//#import "FlickrHelper.h"
//#import "Region+create.h"
//#import "DocumentHelper.h"
#import "Region.h"
#import "PhotoDatabaseAvailability.h"
#import "RegionPhotoCDTVC.h"

@interface TopRegionCDTVC ()

@end

@implementation TopRegionCDTVC

-(void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserverForName:PhotoDatabaseAvailabilityNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"in top region awake");
                                                      self.manageObjectContext = note.userInfo[PhotoDatabaseAvailabilityContext];
                                                  }];
}

-(void)contextChanged:(NSNotification *)notification {
    [self performFetch];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextChanged:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.manageObjectContext];
    NSLog(@"topregion");
}
/*
-(void)viewWillDisappear {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:self.manageObjectContext];
    //[super viewWillDisappear];
}*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#define NUMBER_OF_SHOWN_REGIONS 50
-(void) setManageObjectContext:(NSManagedObjectContext *)manageObjectContext
{
    _manageObjectContext = manageObjectContext;
    NSLog(@"set managedObject");
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
    request.predicate = [NSPredicate predicateWithFormat:@"num_photos > 0"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"num_photographers"
                                                              ascending:NO],
                                [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                              ascending:YES
                                                               selector:@selector(localizedCaseInsensitiveCompare:)]];
    request.fetchLimit = NUMBER_OF_SHOWN_REGIONS;
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:manageObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Region Cell"];
    
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //NSLog(@"region is %@", region);
    
    cell.textLabel.text = region.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ photographers %@ photos", region.num_photographers,region.num_photos];
    //NSLog(@"num_photos is %@", region.num_photos );
    return cell;
}


#pragma mark - Navigation

-(void)prepareViewController:(id)vc forSegue:(NSString *)segueIdentifer fromIndexPaht:(NSIndexPath *) indexPath
{
    Region *region = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([vc isKindOfClass:[RegionPhotoCDTVC class]]) {
        //NSLog(@"Region to segue is %@", region);
        RegionPhotoCDTVC  *regionPhotoCDTVC = (RegionPhotoCDTVC *)vc;
        regionPhotoCDTVC.region = region;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSIndexPath *indexPath = nil;
    if ([[segue identifier] isEqualToString:@"Photos"]) {
    if([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    //NSLog(@"indexPath is %@", indexPath);
    [self prepareViewController:segue.destinationViewController
                       forSegue:segue.identifier
                  fromIndexPaht:indexPath];
    }
}


@end
