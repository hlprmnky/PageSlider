//
//  pageSlider.h
//  page-slider
//
//  Created by Chris Johnson Bidler on 5/5/15.
//  Copyright (c) 2015 Chris Johnson Bidler. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol PageSliderDataSource

-(void) resetData;
-(void) scrollCursorDidReachEndOfData;

@end

@interface PageSlider : UIScrollView <UIScrollViewDelegate>

UIKIT_EXTERN NSString *const PageSliderModelUpdateNotification;

@property (nonatomic, strong) UIView *labelContainerView;
@property (nonatomic, weak) id<PageSliderDataSource> dataSource;

-(void) initWithLabelWidth:(CGFloat)width
               labelHeight:(CGFloat)height
                   contents:(NSArray *)contents;
-(void) loadScrollViewWithPage:(NSUInteger)page;

@end