//
//  SPMapViewController.h
//  Spy
//
//  Created by Robert Mao on 10/27/13.
//  Copyright (c) 2013 Spy Hackathon Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SPMapViewController : UIViewController<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;

@end
