//
//  RDGliderViewController.m
//  GliderSample
//
//  Created by Guillermo Delgado on 14/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GliderSampleTests-Swift.h"

@interface RDGliderViewController (Test)

@property (nonatomic) RDScrollView *scrollView;
- (NSInteger)nearestOffsetIndexTo:(CGPoint)contentOffset;

@end

@interface RDGliderViewControllerTests : XCTestCase <RDGliderViewControllerDelegate> {
    XCTestExpectation *_testExpWill;
    XCTestExpectation *_testExpDid;
}

@property (nonatomic) RDGliderViewController *gliderVC;

@end

@implementation RDGliderViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.gliderVC = [[RDGliderViewController alloc] initWithParent:[UIViewController new]
                                                       WithContent:[RDGliderContentViewController new]
                                                           AndType:RDScrollViewOrientationTypeRDScrollViewOrientationRightToLeft
                                                       WithOffsets:@[@0, @1]];
    self.gliderVC.delegate = self;
    XCTAssertNotNil(self.gliderVC);
}

- (void)tearDown {
    self.gliderVC = nil;
    [super tearDown];
}

- (void)testOffsets {
    NSArray *ar = @[@0, @1];
    XCTAssertTrue([[self.gliderVC offsets] isEqualToArray:ar]);
    XCTAssertThrows([self.gliderVC setOffsets:@[]]);
    
    [self.gliderVC setOffsets:@[@0, @0.5, @1]];
    
    XCTAssertTrue(self.gliderVC.marginOffset == self.gliderVC.scrollView.margin);

    self.gliderVC.scrollView = nil;
    XCTAssertThrows([self.gliderVC setOffsets:@[@0]]);
    XCTAssertThrows([self.gliderVC offsets]);
    XCTAssertTrue(self.gliderVC.currentOffsetIndex == 0);
    XCTAssertTrue(self.gliderVC.marginOffset == 0.0f);
}

- (void)testOrientationType {
    XCTAssertTrue([self.gliderVC orientationType] == RDScrollViewOrientationTypeRDScrollViewOrientationRightToLeft);
    
    self.gliderVC.scrollView = nil;
    XCTAssertTrue([self.gliderVC orientationType] == RDScrollViewOrientationTypeRDScrollViewOrientationUnknown);
}

- (void)testContentViewController {
    
    XCTAssertThrows([self.gliderVC setContentViewControllerWithContent:[self nilReturnMethod]
                                                               AndType:RDScrollViewOrientationTypeRDScrollViewOrientationUnknown
                                                           WithOffsets:@[@1]]);
    
    XCTAssertThrows([self.gliderVC setContentViewControllerWithContent:[RDGliderContentViewController new]
                                                       AndType:RDScrollViewOrientationTypeRDScrollViewOrientationUnknown
                                                    WithOffsets:[self nilReturnMethod]]);
    
    RDGliderContentViewController *contentVC = [RDGliderContentViewController new];
    [self.gliderVC setContentViewControllerWithContent:contentVC
                                               AndType:RDScrollViewOrientationTypeRDScrollViewOrientationRightToLeft
                                           WithOffsets:@[@1]];
    XCTAssertTrue(self.gliderVC.scrollView.orientationType == RDScrollViewOrientationTypeRDScrollViewOrientationRightToLeft);
    XCTAssertTrue([self.gliderVC.scrollView.offsets isEqualToArray:@[@1]]);
}

- (void)testShake {
    CGRect frame = self.gliderVC.scrollView.frame;
    
    [self.gliderVC shake];
    XCTAssertTrue(CGRectEqualToRect(frame, self.gliderVC.scrollView.frame));

    self.gliderVC.scrollView.orientationType = RDScrollViewOrientationTypeRDScrollViewOrientationLeftToRight;
    [self.gliderVC shake];
    XCTAssertTrue(CGRectEqualToRect(frame, self.gliderVC.scrollView.frame));

    self.gliderVC.scrollView.orientationType = RDScrollViewOrientationTypeRDScrollViewOrientationBottomToTop;
    [self.gliderVC shake];
    XCTAssertTrue(CGRectEqualToRect(frame, self.gliderVC.scrollView.frame));

    self.gliderVC.scrollView.orientationType = RDScrollViewOrientationTypeRDScrollViewOrientationTopToBottom;
    [self.gliderVC shake];
    XCTAssertTrue(CGRectEqualToRect(frame, self.gliderVC.scrollView.frame));
}

- (void)testExpand {
    _testExpWill = [self expectationWithDescription:@"Will"];
    _testExpDid = [self expectationWithDescription:@"Did"];
    
    _testExpWill.assertForOverFulfill = NO;
    _testExpDid.assertForOverFulfill = NO;
    
    [self.gliderVC expand];
    
    [self waitForExpectations:@[_testExpDid, _testExpWill] timeout:2];
    XCTAssertTrue([self.gliderVC isOpen]);
}

- (void)testCollapse {
    _testExpWill = [self expectationWithDescription:@"Will"];
    _testExpDid = [self expectationWithDescription:@"Did"];
    
    _testExpWill.assertForOverFulfill = NO;
    _testExpDid.assertForOverFulfill = NO;
    
    [self.gliderVC collapse];
    
    [self waitForExpectations:@[_testExpDid, _testExpWill] timeout:2];
}

- (void)testClose {
    _testExpWill = [self expectationWithDescription:@"Will"];
    _testExpDid = [self expectationWithDescription:@"Did"];
    
    _testExpWill.assertForOverFulfill = NO;
    _testExpDid.assertForOverFulfill = NO;
    
    [self.gliderVC close];

    [self waitForExpectations:@[_testExpDid, _testExpWill] timeout:2];
    XCTAssertFalse([self.gliderVC isOpen]);
}

- (void)testChangeOffset {
    _testExpWill = [self expectationWithDescription:@"Will"];
    _testExpDid = [self expectationWithDescription:@"Did"];
    
    _testExpWill.assertForOverFulfill = NO;
    _testExpDid.assertForOverFulfill = NO;
    
    XCTAssertTrue([self.gliderVC currentOffsetIndex] == 0);

    [self.gliderVC setOffsets:@[@1, @0.5, @0]];
    [self.gliderVC changeOffsetTo:2 animated:NO];
    
    [self waitForExpectations:@[_testExpDid, _testExpWill] timeout:2];
    XCTAssertTrue([self.gliderVC isOpen]);
    XCTAssertTrue([self.gliderVC currentOffsetIndex] == 2);
    
    _testExpWill = [self expectationWithDescription:@"Will"];
    _testExpDid = [self expectationWithDescription:@"Did"];
    
    [self.gliderVC setOffsets:@[@1, @0.5, @0]];
    [self.gliderVC changeOffsetTo:0 animated:NO];
    
    [self waitForExpectations:@[_testExpDid, _testExpWill] timeout:2];
    XCTAssertFalse([self.gliderVC isOpen]);
    XCTAssertTrue([self.gliderVC currentOffsetIndex] == 0);
}

- (void)testNearestOffsetIndex {
    CGPoint point = CGPointMake(0, 0);
    XCTAssertTrue(self.gliderVC.scrollView.orientationType == RDScrollViewOrientationTypeRDScrollViewOrientationRightToLeft);
    XCTAssertTrue([self.gliderVC nearestOffsetIndexTo:point] == 0);

    point = CGPointMake(self.gliderVC.scrollView.contentSize.width, 0);
    self.gliderVC.scrollView.orientationType = RDScrollViewOrientationTypeRDScrollViewOrientationLeftToRight;
    XCTAssertTrue([self.gliderVC nearestOffsetIndexTo:point] == 1);

    point = CGPointMake(0, self.gliderVC.scrollView.contentSize.width / 2.5);
    self.gliderVC.scrollView.orientationType = RDScrollViewOrientationTypeRDScrollViewOrientationBottomToTop;
    XCTAssertTrue([self.gliderVC nearestOffsetIndexTo:point] == 0);
    
    point = CGPointMake(0, self.gliderVC.scrollView.contentSize.width / 1.4);
    self.gliderVC.scrollView.orientationType = RDScrollViewOrientationTypeRDScrollViewOrientationTopToBottom;
    XCTAssertTrue([self.gliderVC nearestOffsetIndexTo:point] == 1);
}

#pragma mark - Helper methods

- (id)nilReturnMethod {
    return nil;
}

- (void)glideViewControllerWithGlideViewController:(nonnull RDGliderViewController *)glideViewController
  hasChangedOffsetOfContent:(CGPoint)offset {
    XCTAssertNotNil(glideViewController);

}

- (void)glideViewControllerWillExpandWithGlideViewController:(nonnull RDGliderViewController *)glideViewController {
    XCTAssertNotNil(glideViewController);
    [_testExpWill fulfill];
}

- (void)glideViewControllerWillCollapseWithGlideViewController:(nonnull RDGliderViewController *)glideViewController {
    XCTAssertNotNil(glideViewController);
    [_testExpWill fulfill];
}

- (void)glideViewControllerDidExpandWithGlideViewController:(nonnull RDGliderViewController *)glideViewController {
    XCTAssertNotNil(glideViewController);
    [_testExpDid fulfill];
}

- (void)glideViewControllerDidCollapseWithGlideViewController:(nonnull RDGliderViewController *)glideViewController {
    XCTAssertNotNil(glideViewController);
    [_testExpDid fulfill];
}


@end
