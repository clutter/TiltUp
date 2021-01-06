//
//  Sequence+sumTests.swift
//  TiltUp_Tests
//
//  Created by Erik Strottmann on 12/15/20.
//  Copyright © 2020 Clutter. All rights reserved.
//

import XCTest

import TiltUp

final class SequenceSumTests: XCTestCase {
    func testSum() {
        let numbers = [1, -2, 3, -4]
        XCTAssertEqual(numbers.sum(), -2)
    }

    func testSumWithTransformClosure() {
        let numbers = [1.1, 3.3, 5.5, 7.7, 9.9]
        XCTAssertEqual(numbers.sum { $0.rounded() }, 28.0, accuracy: 0.001)
    }

    func testSumWithTransformKeyPath() {
        let strings = ["aleph", "omega", "double-yoo"]
        XCTAssertEqual(strings.sum(\.count.description.count), 4)
    }
}
