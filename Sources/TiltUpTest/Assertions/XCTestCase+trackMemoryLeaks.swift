//
//  XCTestCase+trackMemoryLeaks.swift
//  TiltUpTest
//
//  Created by Michael Mattson on 3/2/21.
//

import XCTest

public extension XCTestCase {
    func trackMemoryLeaks(_ objects: AnyObject..., file: StaticString = #file, line: UInt = #line) {
        for object in objects {
            addTeardownBlock { [weak object] in
                XCTAssertNil(object, "Object should have been deallocated. Potential memory leak.", file: file, line: line)
            }
        }
    }
}
