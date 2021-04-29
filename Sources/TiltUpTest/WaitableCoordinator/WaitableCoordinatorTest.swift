//
//  WaitableCoordinatorTest.swift
//  TiltUpTest
//
//  Created by Robert Manson on 9/2/20.
//  Copyright © 2020 Clutter Inc. All rights reserved.
//

import Combine
import XCTest

import TiltUp

public protocol WaitableCoordinatorTest: class { }

public extension WaitableCoordinatorTest where Self: XCTestCase {
    func waitForTopViewControllerChange<T: Coordinator>(using coordinator: T, work: () -> Void) {
        let viewControllerChangedExpectation = XCTestExpectation(description: "Wait for top VC Change Using \(String(describing: T.self))")
        var viewControllerChanged: AnyCancellable?
        viewControllerChanged = coordinator.router.topViewControllerSubject.sink { _ in
            viewControllerChangedExpectation.fulfill()
            viewControllerChanged?.cancel()
        }
        work()
        wait(for: [viewControllerChangedExpectation])
    }

    func waitForPresentedViewControllerChange<T: Coordinator>(using coordinator: T, work: () -> Void) {
        let viewControllerChangedExpectation = XCTestExpectation(description: "Wait for presented VC Change Using \(String(describing: T.self))")
        var viewControllerChanged: AnyCancellable?
        viewControllerChanged = coordinator.router.presentedViewControllerSubject.sink { _ in
            viewControllerChangedExpectation.fulfill()
            viewControllerChanged?.cancel()
        }
        work()
        wait(for: [viewControllerChangedExpectation])
    }

    func waitForTopViewControllerChange(in router: Router, work: () -> Void) {
        let viewControllerChangedExpectation = XCTestExpectation(description: "Wait for top VC Change in \(String(describing: router.self))")
        var viewControllerChanged: AnyCancellable?
        viewControllerChanged = router.topViewControllerSubject.sink { _ in
            viewControllerChangedExpectation.fulfill()
            viewControllerChanged?.cancel()
        }
        work()
        wait(for: [viewControllerChangedExpectation])
    }

    func waitForPresentedViewControllerChange(in router: Router, work: () -> Void) {
        let viewControllerChangedExpectation = XCTestExpectation(description: "Wait for presented VC Change in \(String(describing: router.self))")
        var viewControllerChanged: AnyCancellable?
        viewControllerChanged = router.presentedViewControllerSubject.sink { _ in
            viewControllerChangedExpectation.fulfill()
            viewControllerChanged?.cancel()
        }
        work()
        wait(for: [viewControllerChangedExpectation])
    }
}