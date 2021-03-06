//
//  SPM2XService.h
//  Spy
//
//  Created by Robert Mao on 10/26/13.
//  Copyright (c) 2013 Spy Hackathon Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SPM2XService : NSObject

+ (SPM2XService*) sharedInstance;
- (void) addDataRow:(NSString*)row;
- (void) pullDataRows;

- (int) ptCounts;
- (CLLocationCoordinate2D*) pttracks;

@end
