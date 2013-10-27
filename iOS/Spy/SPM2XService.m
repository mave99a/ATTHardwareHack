//
//  SPM2XService.m
//  Spy
//
//  Created by Robert Mao on 10/26/13.
//  Copyright (c) 2013 Spy Hackathon Team. All rights reserved.
//

#import "SPM2XService.h"
#import "AFNetworking.h"
#import "JSONKit.h"

static NSString* m2xendpoint = @"http://api-m2x.att.com/v1/feeds/10c46f0efccda92bbcd17baf812a6e65/streams/location-timestamp/values";
static NSString* m2xkey = @"fab153cc39ddd93134902a209c3e4221";
static NSString* m2xheader = @"X-M2X-KEY";

static CLLocationCoordinate2D tracks[1000];
static int count = 0;

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

- (void) addDataRow:(NSString*)row
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager.requestSerializer setValue: m2xkey forHTTPHeaderField:m2xheader];
    [manager.requestSerializer setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{@"values":@[@{@"value":row}]};
    
    [manager POST:m2xendpoint parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) pullDataRows
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    [manager.requestSerializer setValue: m2xkey forHTTPHeaderField:m2xheader];
    [manager.requestSerializer setValue: @"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [manager GET:m2xendpoint parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* response = (NSDictionary*)responseObject;
        
        count = 0;
        for (NSDictionary* value in response[@"values"]) {
            NSString* str = value[@"value"];
            NSDictionary *deserializedData = [str objectFromJSONString];
            
            if (deserializedData != nil) {
                CLLocationCoordinate2D pt = CLLocationCoordinate2DMake([deserializedData[@"lat"] floatValue], [deserializedData[@"lng"] floatValue]);
                //[_track addObject:pt];
                if (count> 1000) break;
                
                tracks[count++] = pt;
            }
            else {
                NSLog(@"[warning] ignore invalid row: %@", str);
            }
        }
        
        NSLog(@"Total %d points", count);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (int)ptCounts
{
    return count;
}

- (CLLocationCoordinate2D*) pttracks
{
    return tracks;
}

@end
