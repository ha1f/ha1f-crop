//
//  CornerPositionTests.swift
//  ha1f-cropTests
//
//  Created by ST20591 on 2017/10/19.
//  Copyright © 2017年 ha1f. All rights reserved.
//

import UIKit
import XCTest

@testable import ha1f_crop

class CornerPositionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsTop() {
        XCTAssertTrue(CornerPosition.topLeft.isTopEdge)
        XCTAssertTrue(CornerPosition.topRight.isTopEdge)
        XCTAssertFalse(CornerPosition.bottomLeft.isTopEdge)
        XCTAssertFalse(CornerPosition.bottomRight.isTopEdge)
    }
    
    func testIsRight() {
        XCTAssertFalse(CornerPosition.topLeft.isRightEdge)
        XCTAssertTrue(CornerPosition.topRight.isRightEdge)
        XCTAssertFalse(CornerPosition.bottomLeft.isRightEdge)
        XCTAssertTrue(CornerPosition.bottomRight.isRightEdge)
    }
    
    func testIsLeft() {
        XCTAssertTrue(CornerPosition.topLeft.isLeftEdge)
        XCTAssertFalse(CornerPosition.topRight.isLeftEdge)
        XCTAssertTrue(CornerPosition.bottomLeft.isLeftEdge)
        XCTAssertFalse(CornerPosition.bottomRight.isLeftEdge)
    }
    
    func testIsBottom() {
        XCTAssertFalse(CornerPosition.topLeft.isBottomEdge)
        XCTAssertFalse(CornerPosition.topRight.isBottomEdge)
        XCTAssertTrue(CornerPosition.bottomLeft.isBottomEdge)
        XCTAssertTrue(CornerPosition.bottomRight.isBottomEdge)
    }
}

