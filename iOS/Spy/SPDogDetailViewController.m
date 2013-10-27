//
//  SPDogDetailViewController.m
//  Spy
//
//  Created by Robert Mao on 10/27/13.
//  Copyright (c) 2013 Spy Hackathon Team. All rights reserved.
//

#import "SPDogDetailViewController.h"
#import "SPM2XService.h"

@interface SPDogDetailViewController ()

@end

@implementation SPDogDetailViewController

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
    
    [[SPM2XService sharedInstance] pullDataRows];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
