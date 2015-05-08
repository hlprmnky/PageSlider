//
//  PSViewController.m
//  PageSlider
//
//  Created by Chris Johnson Bidler on 05/07/2015.
//  Copyright (c) 2014 Chris Johnson Bidler. All rights reserved.
//

#import "PSViewController.h"

@interface PSViewController ()

// Data to send along to the PageSlider
@property(nonatomic, strong) NSMutableArray *data;

@end

@implementation PSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSMutableArray *)data {
    if (! _data) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

#pragma mark PageSliderDataSource
- (void)scrollCursorDidReachEndOfData {
    NSDictionary *message = @{@"shouldReset": @"YES", @"payload": [self.data copy]};
    [[NSNotificationCenter defaultCenter] postNotificationName:PageSliderModelUpdateNotification object:self userInfo:message];
}

- (void)resetData {
    [self.data removeAllObjects];
}

@end
