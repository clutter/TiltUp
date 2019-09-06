//
//  XCTestCase+testUI.swift
//  TiltUpTest
//
//  Created by Jeremy Grenier on 8/7/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

public extension XCTestCase {
    func testUI(setup: @escaping () -> Void, assertions: @escaping () -> Void) {
        let mainThreadExpectation = expectation(description: "Wait for main thread code to run")

        UIView.animate(withDuration: 0.0, animations: setup, completion: { _ in
            assertions()
            mainThreadExpectation.fulfill()
        })

        wait(for: [mainThreadExpectation])
    }
}
