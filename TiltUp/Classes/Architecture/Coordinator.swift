//
//  Coordinator.swift
//  TiltUp
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import UIKit

public protocol Coordinating: AnyObject {
    var appCoordinator: AppCoordinating { get }
    var parent: Coordinating? { get }
    var router: Router { get }

    func start()
}

open class Coordinator: Coordinating {
    unowned public let appCoordinator: AppCoordinating
    public let parent: Coordinating?
    public let router: Router

    // MARK: - Initializers

    public init(appCoordinator: AppCoordinating) {
        self.appCoordinator = appCoordinator
        parent = nil
        router = appCoordinator.router
    }

    public init(parent: Coordinating, modal: Bool) {
        self.parent = parent
        appCoordinator = parent.appCoordinator
        router = modal ? Router() : parent.router
    }

    open func start() {
        fatalError("Subclasses of \(type(of: self)) must override \(#function).")
    }
}

public extension Router {
    // MARK: Pushing
    func push(_ viewController: UIViewController, retaining coordinator: Coordinating, animated: Bool = true, popHandler: (() -> Void)? = nil) {
        coordinator.appCoordinator.pushCoordinator(coordinator)
        push(viewController, animated: animated, popHandler: { [weak coordinator] in
            popHandler?()
            if let coordinator = coordinator {
                coordinator.appCoordinator.popCoordinator(coordinator)
            }
        })
    }

    // MARK: Replacing root
    func replaceRoot(with viewController: UIViewController, retaining coordinator: Coordinating, popHandler: (() -> Void)? = nil) {
        coordinator.appCoordinator.pushCoordinator(coordinator)
        replaceRoot(with: viewController, popHandler: { [weak coordinator] in
            popHandler?()
            if let coordinator = coordinator {
                coordinator.appCoordinator.popCoordinator(coordinator)
            }
        })
    }
}

public extension Router {
    // MARK: Presenting modals
    func presentModal(_ viewController: UIViewController, retaining coordinator: Coordinating, animated: Bool = true, dismissHandler: (() -> Void)? = nil) {
        coordinator.appCoordinator.pushCoordinator(coordinator)
        presentModal(viewController, animated: animated) { [weak coordinator] in
            dismissHandler?()
            if let coordinator = coordinator {
                coordinator.appCoordinator.popCoordinator(coordinator)
            }
        }
    }

    func presentModal(_ router: Router, retaining coordinator: Coordinating, animated: Bool = true, dismissHandler: (() -> Void)? = nil) {
        coordinator.appCoordinator.pushCoordinator(coordinator)
        presentModal(router, animated: animated) { [weak coordinator] in
            dismissHandler?()
            if let coordinator = coordinator {
                coordinator.appCoordinator.popCoordinator(coordinator)
            }
        }
    }
}
