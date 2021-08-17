//
//  CameraCoordinatorTests.swift
//  TiltUp_Tests
//
//  Created by John Brophy on 8/17/21.
//  Copyright © 2021 Clutter. All rights reserved.
//

import XCTest

import TiltUpTest

@testable import TiltUp

final class CameraCoordinatorTests: XCTestCase, WaitableCoordinatorTest {
    private var parent: TestCoordinator!

    override func setUp() {
        parent = TestCoordinator()
    }

    override func tearDown() {
        parent = nil
    }

    func testStartForModal() {
        let coordinator = CameraCoordinator(
            parent: parent,
            modal: true,
            hintProvider: { _ in return nil },
            viewModel: .init(
                settings: .init(numberOfPhotos: 1...1),
                logger: .init(info: { _ in }, bug: { _ in })
            )
        )

        waitForPresentedViewControllerChange(in: parent.router) {
            coordinator.start()
        }

        assertRetained(coordinator, withTopViewControllerOfType: CameraController.self)
    }

    func testStartForNonModal() {
        let coordinator = CameraCoordinator(
            parent: parent,
            modal: false,
            hintProvider: { _ in return nil },
            viewModel: .init(
                settings: .init(numberOfPhotos: 1...1),
                logger: .init(info: { _ in }, bug: { _ in })
            )
        )

        waitForTopViewControllerChange(in: coordinator.router) {
            coordinator.start()
        }

        assertRetained(coordinator, withTopViewControllerOfType: CameraController.self)
    }
}
