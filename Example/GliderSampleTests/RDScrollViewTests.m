//
//  RDScrollViewTests.m
//  GliderSample
//
//  Created by Guillermo Delgado on 27/04/2017.
//  Copyright © 2017 Guillermo Delgado. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GliderSampleTests-Swift.h"

@interface RDScrollView()

@property (nonatomic) NSInteger offsetIndex;

@end

@interface RDScrollViewTests : XCTestCase

@property (nonatomic) RDScrollView *rdScrollView;

@end

@implementation RDScrollViewTests

- (void)setUp {
    [super setUp];
    self.rdScrollView = [[RDScrollView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
}

- (void)tearDown {
    self.rdScrollView = nil;
    [super tearDown];
}

- (void)testInit {
    XCTAssertTrue(self.rdScrollView.margin == 20);
    XCTAssertTrue(self.rdScrollView.orientationType == RDScrollViewOrientationTypeRDScrollViewOrientationRightToLeft);
    XCTAssertFalse(self.rdScrollView.showsVerticalScrollIndicator);
    XCTAssertFalse(self.rdScrollView.showsHorizontalScrollIndicator);
    XCTAssertFalse(self.rdScrollView.bounces);
    XCTAssertFalse(self.rdScrollView.pagingEnabled);
    XCTAssertTrue(UIEdgeInsetsEqualToEdgeInsets(self.rdScrollView.contentInset, UIEdgeInsetsZero));
    XCTAssertTrue(self.rdScrollView.decelerationRate == UIScrollViewDecelerationRateFast);
}

- (void)testExpandOffset {
    XCTestExpectation *ex0 = [self expectationWithDescription:@"Success0"];
    
    [self.rdScrollView expandWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex0 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 0);
        }
    }];
    
    [self.rdScrollView setOffsets:@[@0,@.5,@1]];
    
    XCTAssertTrue([[self.rdScrollView offsets] count] == 3);
    XCTAssertTrue([self.rdScrollView offsetIndex] == 0);
    
    XCTestExpectation *ex1 = [self expectationWithDescription:@"Success1"];
    
    [self.rdScrollView expandWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex1 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 1);
        }
    }];
    
    [self waitForExpectations:@[ex0, ex1] timeout:2];
    
    XCTAssertTrue([self.rdScrollView offsetIndex] == 1);
    
    XCTestExpectation *ex2 = [self expectationWithDescription:@"Success2"];
    
    [self.rdScrollView expandWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex2 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 2);
        }
    }];
    
    [self waitForExpectations:@[ex2] timeout:2];
    
    XCTAssertTrue([self.rdScrollView offsetIndex] == 2);
    
    XCTestExpectation *ex3 = [self expectationWithDescription:@"Success3"];
    
    [self.rdScrollView expandWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex3 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 2);
        }
    }];
    
    [self waitForExpectations:@[ex3] timeout:2];
}

- (void)testCollapseOffset {
    [self.rdScrollView setOffsets:@[@0,@.5,@1]];
    [self.rdScrollView setOffsetIndex:[[self.rdScrollView offsets] count] - 1];
    
    XCTAssertTrue([[self.rdScrollView offsets] count] == 3);
    XCTAssertTrue([self.rdScrollView offsetIndex] == 2);
    
    XCTestExpectation *ex1 = [self expectationWithDescription:@"Success1"];
    
    [self.rdScrollView collapseWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex1 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 1);
        }
    }];
    
    [self waitForExpectations:@[ex1] timeout:2];
    
    XCTestExpectation *ex2 = [self expectationWithDescription:@"Success2"];
    
    [self.rdScrollView collapseWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex2 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 0);
        }
    }];
    
    [self waitForExpectations:@[ex2] timeout:2];
    XCTestExpectation *ex3 = [self expectationWithDescription:@"Success3"];
    
    [self.rdScrollView collapseWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex3 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 0);
        }
    }];
    
    [self waitForExpectations:@[ex3] timeout:2];
}

- (void)testCloseOffset {
    XCTestExpectation *ex0 = [self expectationWithDescription:@"Success0"];
    
    [self.rdScrollView closeWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex0 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 0);
        }
    }];
    
    [self.rdScrollView setOffsets:@[@0,@.5,@1]];
    
    XCTAssertTrue([[self.rdScrollView offsets] count] == 3);
    XCTAssertTrue([self.rdScrollView offsetIndex] == 0);
    
    XCTestExpectation *ex1 = [self expectationWithDescription:@"Success1"];
    
    [self.rdScrollView closeWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex1 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 0);
        }
    }];
    
    [self waitForExpectations:@[ex0, ex1] timeout:2];
    
    [self.rdScrollView setOffsetIndex:[[self.rdScrollView offsets] count] - 1];
    
    XCTAssertTrue([[self.rdScrollView offsets] count] == 3);
    XCTAssertTrue([self.rdScrollView offsetIndex] == 2);
    
    XCTestExpectation *ex2 = [self expectationWithDescription:@"Success2"];
    
    [self.rdScrollView closeWithCompletionWithCompletion:^(BOOL finished) {
        if (finished) {
            [ex2 fulfill];
            XCTAssertTrue([self.rdScrollView offsetIndex] == 0);
        }
    }];
    
    [self waitForExpectations:@[ex2] timeout:2];
}

- (void)testOffsets {
    NSArray *ar = @[@0, @3, @0.123];
    XCTAssertThrows([self.rdScrollView setOffsets:ar]);
    
    XCTAssertTrue(self.rdScrollView.orientationType == RDScrollViewOrientationTypeRDScrollViewOrientationRightToLeft);
    
    ar = @[@1, @0.6, @0.3, @0];
    [self.rdScrollView setOffsets:ar];
    
    XCTAssertTrue([[self.rdScrollView offsets] isEqualToArray:
                   [ar sortedArrayUsingSelector:@selector(compare:)]]);
    
    [self.rdScrollView setOrientationType:RDScrollViewOrientationTypeRDScrollViewOrientationBottomToTop];
    XCTAssertTrue(self.rdScrollView.orientationType == RDScrollViewOrientationTypeRDScrollViewOrientationBottomToTop);
    
    ar = @[@1, @0.4, @0.3, @0.4];
    [self.rdScrollView setOffsets:ar];
    
    NSArray<NSNumber *> *aux = @[@0.3, @0.4, @1];
    XCTAssertTrue([[self.rdScrollView offsets] isEqualToArray:aux]);
    
    [self.rdScrollView setOrientationType:RDScrollViewOrientationTypeRDScrollViewOrientationLeftToRight];
    XCTAssertTrue(self.rdScrollView.orientationType == RDScrollViewOrientationTypeRDScrollViewOrientationLeftToRight);
    
    [self.rdScrollView setOffsets:ar];
    
    aux = @[@0.7, @0.6, @0];
    
    for (int i = 0 ; i < [self.rdScrollView.offsets count] - 1 ; i++) {
        XCTAssertTrue(self.rdScrollView.offsets[i].floatValue == aux[i].floatValue);
    }
    
    [self.rdScrollView setOrientationType:RDScrollViewOrientationTypeRDScrollViewOrientationTopToBottom];
    XCTAssertTrue(self.rdScrollView.orientationType == RDScrollViewOrientationTypeRDScrollViewOrientationTopToBottom);
    
    ar = @[@0, @0.5, @1];
    [self.rdScrollView setOffsets:ar];
    
    aux = @[@1, @0.5, @0];
    XCTAssertTrue([[self.rdScrollView offsets] isEqualToArray:aux]);
}

@end
