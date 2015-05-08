//
//  PageSliderTests.m
//  PageSliderTests
//
//  Created by Chris Johnson Bidler on 05/07/2015.
//  Copyright (c) 2014 Chris Johnson Bidler. All rights reserved.
//

#import "PageSlider.h"
#import "PSViewController.h"



SpecBegin(PageSliderDataSource)

describe(@"DataSource", ^{
    it(@"Can create an NSNotification when prompted for data", ^{
        [[NSNotificationCenter defaultCenter]
         addObserverForName:@""
         object:nil
         queue:nil usingBlock:^(NSNotification *note) {
             expect(note).toNot.beNil;
             expect(note).to.beMemberOf([NSDictionary class]);
             NSDictionary *dictionary = (NSDictionary *)note;
             expect([dictionary objectForKey:@"payload"]).to.beMemberOf([NSArray class]);
             expect([dictionary objectForKey:@"shouldReset"]).to.equal(@"YES");
         }];
        id<PageSliderDataSource> dataSource = [[PSViewController alloc] init];
        [dataSource scrollCursorDidReachEndOfData];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
});

SpecEnd
