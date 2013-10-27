//
//  SPiBeaconManager.m
//  Spy
//
//  Created by Robert Mao on 10/26/13.
//  Copyright (c) 2013 Spy Hackathon Team. All rights reserved.
//

#import "SPiBeaconManager.h"
#import "SPM2XService.h"
#import "JSONKit.h"
#import <CoreBluetooth/CoreBluetooth.h>

static NSString * const kUUID = @"00000000-0000-0000-0000-000000000000";
static NSString * const kIdentifier = @"aaaIdentifier";
static NSString * const kCellIdentifier = @"BeaconCell";
static CLProximity lastproximity = CLProximityUnknown;

@interface SPiBeaconManager ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) CBPeripheralManager *peripheralManager;
@property (nonatomic, strong) CLLocation * lastLocation;
@property (nonatomic, strong) CLLocation * lastPubLocation;

@end

@implementation SPiBeaconManager

+ (SPiBeaconManager*) sharedInstance
{
    static SPiBeaconManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SPiBeaconManager alloc] init];
        
    });
    
    return _sharedInstance;
}

- (void) publishLocation
{
    if (_lastLocation == nil)
        return;
    
    NSDictionary* location = @{
                               @"lat":[NSNumber numberWithFloat:_lastLocation.coordinate.latitude],
                               @"lng":[NSNumber numberWithFloat:_lastLocation.coordinate.longitude]
                               };
    
    NSString* loc = [location JSONString];
    [[SPM2XService sharedInstance] addDataRow:loc];
    _lastPubLocation = _lastLocation;
}

- (void) publishBeacon
{
    CLBeacon *beacon = self.detectedBeacons.lastObject;
    
    if (beacon != nil) {
        
        NSString *proximityString;
        
        switch (beacon.proximity) {
            case CLProximityNear:
                proximityString = @"near";
                break;
            case CLProximityImmediate:
                proximityString = @"am right on";
                break;
            case CLProximityFar:
                proximityString = @"far away from";
                break;
            case CLProximityUnknown:
            default:
                proximityString = @"leaving";
                break;
        }
        
        /*
            NSString* row = [NSString stringWithFormat:@"I am %@ an iBeacon(%@, %@ • %@ • %f • %li) - location:%@", proximityString, beacon.proximityUUID.UUIDString, beacon.major.stringValue, beacon.minor.stringValue, beacon.accuracy, (long)beacon.rssi, _lastLocation];
            
            NSLog(@"[LOG] %@",row); */
        
        if (_lastPubLocation == nil) {
            [self publishLocation];
        }
        else if ([_lastLocation distanceFromLocation:_lastPubLocation] > 10) {
            
            [self publishLocation];
        }
    }
}

#pragma mark - Beacon ranging
- (void)createBeaconRegion
{
    if (self.beaconRegion)
        return;
    
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:kIdentifier];
}

- (void)turnOnRanging
{
    NSLog(@"Turning on ranging...");
    
    if (![CLLocationManager isRangingAvailable]) {
        NSLog(@"Couldn't turn on ranging: Ranging is not available.");
        return;
    }
    
    if (self.locationManager.rangedRegions.count > 0) {
        NSLog(@"Didn't turn on ranging: Ranging already on.");
        return;
    }
    
    [self createBeaconRegion];
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
    [self.locationManager startUpdatingLocation];
    
    NSLog(@"Ranging turned on for region: %@.", self.beaconRegion);
    
    self.m = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.nDevices = [[NSMutableArray alloc]init];
    self.sensorTags = [[NSMutableArray alloc]init];
}


- (void)startRangingForBeacons
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self turnOnRanging];
}

- (void)stopRangingForBeacons
{
    if (self.locationManager.rangedRegions.count == 0) {
        NSLog(@"Didn't turn off ranging: Ranging already off.");
        return;
    }
    
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    
    self.detectedBeacons = nil;
    
    NSLog(@"Turned off ranging.");
}

#pragma mark - Beacon ranging delegate methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Couldn't turn on ranging: Location services are not enabled.");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        NSLog(@"Couldn't turn on ranging: Location services not authorised.");
        return;
    }
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    if ([beacons count] == 0) {
        NSLog(@"No beacons found nearby.");
    } else {
        NSLog(@"Found beacons!");
    }
    
    self.detectedBeacons = beacons;
    
    [self publishBeacon];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    _lastLocation = newLocation;
}

#pragma mark - CBCentralManager delegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state != CBCentralManagerStatePoweredOn) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"BLE not supported !" message:[NSString stringWithFormat:@"CoreBluetooth return state: %d",central.state] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else {
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}




-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Found a BLE Device : %@",peripheral);
    
    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */
    
    peripheral.delegate = self;
    [central connectPeripheral:peripheral options:nil];
    
    [self.nDevices addObject:peripheral];
    
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    [peripheral discoverServices:nil];
}

#pragma  mark - CBPeripheral delegate

-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services scanned !");
    [self.m cancelPeripheralConnection:peripheral];
    for (CBService *s in peripheral.services) {
        NSLog(@"Service found : %@",s.UUID);
        if ([s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]])  {
            NSLog(@"This is a SensorTag !");
            found = YES;
        }
    }
    if (found) {
        // Match if we have this device from before
        for (int ii=0; ii < self.sensorTags.count; ii++) {
            CBPeripheral *p = [self.sensorTags objectAtIndex:ii];
            if ([p isEqual:peripheral]) {
                [self.sensorTags replaceObjectAtIndex:ii withObject:peripheral];
                replace = YES;
            }
        }
        if (!replace) {
            [self.sensorTags addObject:peripheral];
           // [self.tableView reloadData];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}

@end
