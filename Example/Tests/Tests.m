//
//  MASliderTests.m
//  MASliderTests
//
//  Created by mpmarcelomp@gmail.com on 04/07/2017.
//  Copyright (c) 2017 mpmarcelomp@gmail.com. All rights reserved.
//

// https://github.com/Specta/Specta

#import "MASlider.h"

#import <XCTest/XCTest.h>

@interface UIStackViewSampleTests : XCTestCase

@end

@implementation UIStackViewSampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

//SpecBegin(InitialSpecs)

//describe(@"these will fail", ^{
//
//    it(@"can do maths", ^{
//        expect(1).to.equal(2);
//    });
//
//    it(@"can read", ^{
//        expect(@"number").to.equal(@"string");
//    });
//    
//    it(@"will wait for 10 seconds and fail", ^{
//        waitUntil(^(DoneCallback done) {
//        
//        });
//    });
//});

//describe(@"these will pass", ^{
//    
//    it(@"can do maths", ^{
//        expect(1).beLessThan(23);
//    });
//    
//    it(@"can read", ^{
//        expect(@"team").toNot.contain(@"I");
//    });
//    
//    it(@"will wait and succeed", ^{
//        waitUntil(^(DoneCallback done) {
//            done();
//        });
//    });
//});

//SpecEnd

