//
//  AppCoordinator.swift
//  TiltUp
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import UIKit

public protocol AppCoordinating: AnyObject {
    var router: Router { get }
    func pushCoordinator(_ coordinator: Coordinating)
    func popCoordinator(_ coordinator: Coordinating)
    func containsCoordinator(_ coordinator: Coordinating) -> Bool
}

public final class AppCoordinator: AppCoordinating {
    private var coordinators: [ObjectIdentifier: Coordinating] = [:]

    private let window: UIWindow
    public let router = Router()

    private init(window: UIWindow) {
        self.window = window
        window.rootViewController = router.navigationController
    }

    static public func initialize(window: UIWindow) -> AppCoordinator {
        return AppCoordinator(window: window)
    }
}

public extension AppCoordinator {
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

public extension AppCoordinator {
    func start(coordinator: Coordinating) {
        coordinator.start()
        window.makeKeyAndVisible()
    }
}
