//
//  SPM2XService.m
//  Spy
//
//  Created by Robert Mao on 10/26/13.
//  Copyright (c) 2013 Spy Hackathon Team. All rights reserved.
//

#import "SPM2XService.h"
#import "AFNetworking.h"

static NSString* m2xendpoint = @"http://api-m2x.att.com/v1/feeds/10c46f0efccda92bbcd17baf812a6e65/streams/location-timestamp/values";
static NSString* m2xkey = @"fab153cc39ddd93134902a209c3e4221";
static NSString* m2xheader = @"X-M2X-KEY";

@implementation SPM2XService

+ (SPM2XService*) sharedInstance
{
    static SPM2XService *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[SPM2XService alloc] init];
    });
    
    return _sharedInstance;
}

- (void) addDataRow
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager.requestSerializer setValue: m2xkey forHTTPHeaderField:m2xheader];
    [manager.requestSerializer setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"values":@[@{@"value":@"lalala test data from iOS"}]};
    
    [manager POST:m2xendpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

@end
