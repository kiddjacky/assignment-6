//
//  AppDelegate.m
//  TopPlaces
//
//  Created by Martin Mandl on 05.12.13.
//  Copyright (c) 2013 m2m server software gmbh. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrHelper.h"
#import "DocumentHelper.h"
#import "Photo+Flickr.h"
#import "PhotoDatabaseAvailability.h"


@implementation AppDelegate


#define FOREGROUND_FLICKR_FETCH_INTERVAL (30)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    [DocumentHelper useDocumentWithOperation:^(UIManagedDocument *document, BOOL success) {
        if (success) {
            NSDictionary *userInfo = document.managedObjectContext ? @{ PhotoDatabaseAvailabilityContext : document.managedObjectContext} : nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                                object:self
                                                              userInfo:userInfo];
            [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                             target:self
                                           selector:@selector(startFlickrFetch:)
                                           userInfo:nil
                                            repeats:YES];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(startCellularFlickrFetch)
                                                         name:STARTCELLULAR
                                                       object:nil];
            [Photo removeOldPhotosFromManagedObjectContext:document.managedObjectContext];
        }
    }];
    [self startFlickrFetch];
    return YES;
}

-(void)startFlickrFetchAllowingCellularAccess:(BOOL)cellular
{
    [FlickrHelper startBackgroundDownloadRecentPhotosOnCompletion:^(NSArray *photos, void (^whenDone) ()) {
        NSLog(@"%lu photos fetched", (unsigned long)[photos count]);
        [self useDocumentWithFlickrPhotos:photos];
        if (whenDone) whenDone();
    } allowingCellularAccess:cellular];
}

-(void) startFlickrFetch:(NSTimer *) timer
{
    [self startFlickrFetch];
}

-(void)startCellularFlickrFetch
{
    [self startFlickrFetchAllowingCellularAccess:YES];
}

-(void) startFlickrFetch
{
    [self startFlickrFetchAllowingCellularAccess:NO];
}

-(void) application:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    [FlickrHelper handleEventsForBackgroundURLSession:identifier
                                    completionHandler:completionHandler];
}


- (void) application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [FlickrHelper loadTopRegionsOnCompletion:^(NSArray *photos, NSError *error) {
        if (error) {
            NSLog(@"Flickr background fetch failed: %@", error);
            completionHandler(UIBackgroundFetchResultFailed);
        }
        else {
            NSLog(@"%lu photos fetched in perform fetch", (unsigned long)[photos count]);
            [self useDocumentWithFlickrPhotos:photos];
            completionHandler(UIBackgroundFetchResultNewData);
        }
    }];
    NSLog(@"in perform Fetch");
}

-(void) useDocumentWithFlickrPhotos:(NSArray *)photos
{
    [DocumentHelper useDocumentWithOperation:^(UIManagedDocument *document, BOOL success) {
        if(success) {
            NSLog(@"success");
            [Photo loadPhotosFromFlickrArray:photos
                    intoManagedObjectContext:document.managedObjectContext];
            [document saveToURL:document.fileURL
               forSaveOperation:UIDocumentSaveForOverwriting
              completionHandler:nil];
        }
    }];
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
