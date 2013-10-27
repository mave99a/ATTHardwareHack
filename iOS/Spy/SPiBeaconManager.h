//
//  SPiBeaconManager.h
//  Spy
//
//  Created by Robert Mao on 10/26/13.
//  Copyright (c) 2013 Spy Hackathon Team. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface SPiBeaconManager : NSObject<CLLocationManagerDelegate>
@property (nonatomic, strong) NSArray *detectedBeacons;

+ (SPiBeaconManager*) sharedInstance;
- (void)startRangingForBeacons;
- (void)stopRangingForBeacons;

@end
