//
//  pageSlider.m
//  page-slider
//
//  Created by Chris Johnson Bidler on 5/5/15.
//  Copyright (c) 2015 Chris Johnson Bidler. All rights reserved.
//

#import "pageSlider.h"

NSString *const PageSliderModelUpdateNotification = @"PageSliderModelUpdateNotification";

#define NUMBER_OF_LABELS 3

@interface PageSlider () {
    CGFloat labelWidth, labelHeight;
    int currentPage;
    BOOL shouldClearData;
    
}
@property (nonatomic, strong) NSMutableArray *controllers;
@property (nonatomic, strong) UIView *currentContent;
@property (nonatomic, strong) NSArray *contents;
@end

@implementation PageSlider

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.controllers = [self setupControllers];
        [self setupViewState];
        [self setUpNotificationListeners];
    }
    return self;
}

- (void) initWithLabelWidth:(CGFloat)width
                labelHeight:(CGFloat)height
                   contents:(NSArray *)initialContents
{
    labelWidth =  width;
    labelHeight = height;
    self.contents = initialContents;
    shouldClearData = NO;
    self.controllers = [self setupControllers];
    
    self.labelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelWidth * NUMBER_OF_LABELS, labelHeight)];
    [self addSubview:self.labelContainerView];
    [self setupViewState];
    [self setUpNotificationListeners];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    // Add content subview
    [self.labelContainerView setUserInteractionEnabled:NO];
    [self addSubview:self.labelContainerView];
}

- (void) dealloc {
    [self.dataSource resetData];
    [self tearDownNotificationListeners];
}

- (void) setupViewState {
    // a page is the width of the scroll view
    [self setPagingEnabled:YES];
    [self setClipsToBounds:YES];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setContentSize:CGSizeMake(labelWidth * NUMBER_OF_LABELS, labelHeight)];
    [self setShowsHorizontalScrollIndicator:NO];
    [self setShowsVerticalScrollIndicator:NO];
    [self setScrollsToTop:NO];
    [self setBounces:YES];
    [self setBouncesZoom:NO];
    [self setDelegate:self];
}

- (UIView *)currentContent
{
    if (! _currentContent) {
        _currentContent = [[UIView alloc] init];
    }
    return _currentContent;
}

- (UIView *)labelContainerView
{
    if (! _labelContainerView) {
        _labelContainerView = [[UIView alloc] init];
    }
    return _labelContainerView;
}

- (NSMutableArray *) setupControllers
{
    
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:NUMBER_OF_LABELS];
    for (int i = 0; i < NUMBER_OF_LABELS; i++) {
        UIViewController *controller = [[UIViewController alloc] init];
        controller.view = self.contents[i];
        CGRect frame = CGRectMake(i * labelWidth,
                                  0,
                                  labelWidth,
                                  labelHeight);
        controller.view.frame = frame;
        [self.labelContainerView addSubview:controller.view];
        [controllers addObject:controller];
    }
    return controllers;
}

- (void) resetControllerContents
{
    for (int i = 0; i < NUMBER_OF_LABELS; i++) {
        UIViewController *controller = self.controllers[i];
        controller.view = self.contents[i];
    }
    [self resetCurrentContent];
    [self setNeedsDisplay];
}

- (void) loadScrollViewWithPage:(NSUInteger)page
{
    // Bounds checking for edges being loaded before new contents are ready
    if (page < 1)
        return;
    if (page >= self.contents.count - 1)
        return;
    if ([self.contents count] < 1)
        return;
    
    int midpoint = (int)floor(NUMBER_OF_LABELS / 2.0);
    for (int i = 0; i < NUMBER_OF_LABELS; i++) {
        NSUInteger pageOffset = page - (midpoint - i);
        UIViewController *controller = self.controllers[i];
        controller.view = self.contents[pageOffset];
    }
    
    //Recenter on the middle label
    float labelCenter = (self.contentSize.width / 2) - (labelWidth / 2);
    self.contentOffset = CGPointMake(labelCenter, self.contentOffset.y);
    
    //Possibly reset current content
    [self resetCurrentContent];
    [self setNeedsDisplay];
}

- (void) resetCurrentContent
{
    for (UIViewController *controller in self.controllers) {
        CGRect visibleBounds = [self convertRect:self.bounds toView:self.labelContainerView];
        CGPoint labelCenter =
        [controller.view convertPoint:controller.view.center
                               toView:self.labelContainerView];
        if (labelCenter.x > visibleBounds.origin.x  &&
            labelCenter.x < visibleBounds.origin.x + visibleBounds.size.width) {
            self.currentContent = controller.view;
        }
    }
}


-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    BOOL shouldRecenterView = NO;
    CGRect visibleBounds = [self convertRect:self.bounds toView:self.labelContainerView];
    for (UIViewController *controller in self.controllers) {
        
        CGPoint viewCenter = [controller.view convertPoint:controller.view.center toView:self.labelContainerView];
        CGRect viewBounds = [controller.view convertRect:controller.view.frame toView:self.labelContainerView];
        if (viewCenter.x > visibleBounds.origin.x  &&
            viewCenter.x < visibleBounds.origin.x + visibleBounds.size.width) {
            self.currentContent = controller.view;
            if (viewBounds.origin.x == visibleBounds.origin.x ||
                viewBounds.origin.x + viewBounds.size.width == visibleBounds.size.width) {
                shouldRecenterView = YES;
            }
        }
        
    }
    if ([scrollView isEqual:[self.contents lastObject]]) {
        [self.dataSource scrollCursorDidReachEndOfData];
    }
    if (shouldRecenterView) {
        NSUInteger page = [self.contents indexOfObject:self.currentContent];
        [self loadScrollViewWithPage:page];
    }
}

-(void) setUpNotificationListeners
{
    __weak PageSlider *weakSelf = self;
    [[NSNotificationCenter defaultCenter]
     addObserverForName:PageSliderModelUpdateNotification
     object:nil
     queue:nil
     usingBlock:^(NSNotification * notification){
         id object = notification.object;
         if([object isKindOfClass:[NSDictionary class]]) {
             NSDictionary* payload = (NSDictionary *)object;
             BOOL shouldReset = [payload objectForKey:@"shouldReset"];
             NSArray* views = [payload objectForKey:@"views"];
             
             if(shouldReset) {
                 weakSelf.contents = views;
             } else {
                 NSMutableArray* tmp = [[NSMutableArray alloc] init];
                 [tmp addObjectsFromArray:weakSelf.contents];
                 [tmp addObjectsFromArray:views];
                 weakSelf.contents = [tmp copy];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (shouldReset) {
                     [weakSelf resetControllerContents];
                 } else {
                     [weakSelf setNeedsDisplay];
                 }
             });
         }
     }];
}

-(void) tearDownNotificationListeners
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
