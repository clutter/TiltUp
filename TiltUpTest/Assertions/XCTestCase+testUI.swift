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
        var cancellableSetup: (() -> Void)? = setup
        var cancellableAssertions: (() -> Void)? = assertions
        let mainThreadExpectation = expectation(description: "Wait for main thread code to run")
        UIView.animate(
            withDuration: 0.0,
            animations: {
                cancellableSetup?()
            },
            completion: { _ in
                cancellableAssertions?()
                mainThreadExpectation.fulfill()
            }
        )

        wait(for: [mainThreadExpectation])
        cancellableSetup = nil
        cancellableAssertions = nil
    }
}
