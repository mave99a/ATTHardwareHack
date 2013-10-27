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

@interface SPiBeaconManager : NSObject<CLLocationManagerDelegate, CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic, strong) NSArray *detectedBeacons;

@property (strong,nonatomic) CBCentralManager *m;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *sensorTags;

+ (SPiBeaconManager*) sharedInstance;
- (void)startRangingForBeacons;
- (void)stopRangingForBeacons;

@end
