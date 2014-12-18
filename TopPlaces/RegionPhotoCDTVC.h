//
//  RegionPhotoCDTVC.h
//  TopPlaces
//
//  Created by kiddjacky on 12/14/14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Region.h"
#import "Photo.h"
#import "Recent.h"
#import "PhotosTVC.h"

@interface RegionPhotoCDTVC : PhotosTVC

@property (nonatomic, strong) Region *region;
@end
