//
//  XCTestCase+wait.swift
//  ForkliftTests
//
//  Created by Jeremy Grenier on 4/3/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

public extension XCTestCase {
    func wait(for expectations: [XCTestExpectation]) {
        wait(for: expectations, timeout: 1.0)
    }
}
