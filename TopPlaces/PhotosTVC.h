//
//  PhotosTVC.h
//  TopPlaces
//
//  Created by Martin Mandl on 06.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PhotosTVC : CoreDataTableViewController

-(void) prepareViewController:(id)vc forSegue:(NSString *)segueIdentifer fromIndexPath:(NSIndexPath *)indexPath;

@end
