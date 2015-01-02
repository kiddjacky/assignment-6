//
//  RegionMapViewController.m
//  TopPlaces
//
//  Created by kiddjacky on 1/1/15.
//  Copyright (c) 2015 m2m server software gmbh. All rights reserved.
//

#import "RegionMapViewController.h"
#import <MapKit/MapKit.h>
#import "Photo+annotation.h"
#import "ImageVC.h"


@interface RegionMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSArray *photosByRegion;
@end

@implementation RegionMapViewController

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *reuseId = @"RegionMapViewController";
    MKAnnotationView *view = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        view.canShowCallout = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        view.leftCalloutAccessoryView = imageView;
        UIButton *disclosureButton = [[UIButton alloc] init];
        [disclosureButton setBackgroundImage:[UIImage imageNamed:@"disclosure"] forState:UIControlStateNormal];
        [disclosureButton sizeToFit];
        view.rightCalloutAccessoryView = disclosureButton;
    }
    view.annotation = annotation;
    return view;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [self updateLeftCalloutAccessoryViewInAnnotationView:view];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"Show Photos" sender:view];
}

// checks to be sure that the annotationView's left callout is a UIImageView
// if it is and if the annotation is a Photo, then shows the thumbnail
// this should do that fetch in another thread
// but when the thumbnail image came back, it would need to double check the annotationView
// to be sure it is still displaying the annotation for which we fetched
// (because MKAnnotationViews, like UITableViewCells, are reused)

- (void)updateLeftCalloutAccessoryViewInAnnotationView:(MKAnnotationView *)annotationView
{
    UIImageView *imageView = nil;
    if ([annotationView.leftCalloutAccessoryView isKindOfClass:[UIImageView class]]) {
        imageView = (UIImageView *)annotationView.leftCalloutAccessoryView;
    }
    if (imageView) {
        Photo *photo = nil;
        if ([annotationView.annotation isKindOfClass:[Photo class]]) {
            photo = (Photo *)annotationView.annotation;
        }
        if (photo) {
#warning Blocking main queue!
            imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photo.thumbnailURL]]];
        }
    }
}

-(void)updateMapViewAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.photosByRegion];
    [self.mapView showAnnotations:self.photosByRegion animated:YES];
}

-(void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapViewAnnotations];
}

-(void)setRegion:(Region *)region
{
    _region = region;
    self.title = region.name;
    self.photosByRegion = nil;
    [self updateMapViewAnnotations];
}

- (NSArray *)photosByRegion
{
    if (!_photosByRegion) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"region = %@", self.region];
        _photosByRegion = [self.region.managedObjectContext executeFetchRequest:request error:NULL];
    }
    return _photosByRegion;
}

#pragma mark - Navigation

// if the annotation is a Photo, this passes its imageURL to vc (if vc is an ImageViewController)

- (void)prepareViewController:(id)vc
                     forSegue:(NSString *)segueIdentifier
             toShowAnnotation:(id <MKAnnotation>)annotation
{
    Photo *photo = nil;
    if ([annotation isKindOfClass:[Photo class]]) {
        photo = (Photo *)annotation;
    }
    if (photo) {
        if (![segueIdentifier length] || [segueIdentifier isEqualToString:@"Show Photos"]) {
            if ([vc isKindOfClass:[ImageVC class]]) {
                ImageVC *ivc = (ImageVC *)vc;
                ivc.imageURL = [NSURL URLWithString:photo.imageURL];
                ivc.title = photo.title;
            }
        }
    }
}

// if sender is an MKAnnotationView, this calls prepareViewController:forSegue:toShowAnnotation:

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[MKAnnotationView class]]) {
        [self prepareViewController:segue.destinationViewController
                           forSegue:segue.identifier
                   toShowAnnotation:((MKAnnotationView *)sender).annotation];
    }
}

@end
