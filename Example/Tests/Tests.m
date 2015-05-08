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
        waitUntil(^(DoneCallback done) {
            DoneCallback doneNotify = done;
            [[NSNotificationCenter defaultCenter]
             addObserverForName:PageSliderModelUpdateNotification
             object:nil
             queue:nil
             usingBlock:^(NSNotification *note) {
                 id object = note.object;
                 expect(object).toNot.beNil;
                 expect(object).to.beKindOf([NSDictionary class]);
                 NSDictionary *dictionary = (NSDictionary *)note.object;
                 expect([dictionary objectForKey:@"payload"]).to.beKindOf([NSArray class]);
                 expect([dictionary objectForKey:@"shouldReset"]).to.equal(@"YES");
                 doneNotify();
             }];
            id<PageSliderDataSource> dataSource = [[PSViewController alloc] init];
            [dataSource scrollCursorDidReachEndOfData];
        });
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    });
});

SpecEnd
