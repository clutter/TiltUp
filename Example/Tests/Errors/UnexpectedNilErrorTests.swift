//
//  UnexpectedNilErrorTests.swift
//  TiltUpTests
//
//  Created by Erik Strottmann on 9/4/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

import TiltUpTest

final class UnexpectedNilErrorTests: XCTestCase {
    func testThrowing() {
        let error = UnexpectedNilError(expectedType: Any.self, file: #file, line: #line)
        XCTAssertThrowsError(try { throw error }())
    }

    func testLocalizedDescription() {
        let file: StaticString = #file
        let line: UInt = #line
        let error = UnexpectedNilError(expectedType: Any.self, file: file, line: line)
        XCTAssertEqual(error.localizedDescription, "Unexpectedly found nil while unwrapping a value of type Any? at \(file):\(line).")
    }
}
