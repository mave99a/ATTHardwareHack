//
//  SPMapViewController.m
//  Spy
//
//  Created by Robert Mao on 10/27/13.
//  Copyright (c) 2013 Spy Hackathon Team. All rights reserved.
//

#import "SPMapViewController.h"
#import <MapKit/MKOverlay.h>
#import "SPM2XService.h"

@interface SPMapViewController ()

@end

@implementation SPMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _map.delegate = self;
    
    SPM2XService* instance = [SPM2XService sharedInstance];
    
    MKPolyline *route = [MKPolyline polylineWithCoordinates: [instance pttracks] count: [instance ptCounts]];
    [_map addOverlay:route];
    
    [_map setVisibleMapRect:[route boundingMapRect] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
    polylineView.strokeColor = [UIColor greenColor];
    polylineView.lineWidth = 5.0;
    
    return polylineView;
    
}

@end
