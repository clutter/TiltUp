//
//  TestAppCoordinator.swift
//  TiltUpTests
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

import TiltUp

final class TestAppCoordinator: AppCoordinating {
    private var coordinators: [ObjectIdentifier: Coordinating] = [:]
    let router: Router

    let testNavigation: TestNavigationController
    private let window: UIWindow

    init() {
        testNavigation = TestNavigationController(rootViewController: UIViewController())
        router = Router(navigationController: testNavigation)

        // swiftlint:disable:next force_unwrapping
        window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })!
        window.rootViewController = testNavigation
    }

    func start() {
        window.makeKeyAndVisible()
    }
}

extension TestAppCoordinator {
    func pushCoordinator(_ coordinator: Coordinating) {
        coordinators[ObjectIdentifier(coordinator)] = coordinator
    }

    func popCoordinator(_ coordinator: Coordinating) {
        coordinators[ObjectIdentifier(coordinator)] = nil
    }

    func containsCoordinator(_ coordinator: Coordinating) -> Bool {
        return coordinators.keys.contains(ObjectIdentifier(coordinator))
    }
}

// MARK: - Assertions
extension XCTestCase {
    func assertRetained<T: UIViewController>(_ coordinator: Coordinating, withTopViewControllerOfType type: T.Type, message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {

        guard let vc = coordinator.router.navigationController.topViewController else {
            recordFailure(
                withDescription: "assertRetained(_:withTopViewControllerOfType:) failed: topViewController is nil - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            return
        }

        guard coordinator.appCoordinator.containsCoordinator(coordinator) else {
            recordFailure(
                withDescription: "assertRetained(_:withTopViewControllerOfType:) failed: (\"\(coordinator)\") is not retained by app coordinator - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            return
        }

        guard vc is T else {
            recordFailure(
                withDescription: "assertRetained(_:withTopViewControllerOfType:) failed: (\"\(vc)\") is not of type (\"\(T.self)\") - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            return
        }
    }
}
