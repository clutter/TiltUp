//
//  Router.swift
//  TiltUp
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import Combine
import UIKit

public final class Router: NSObject {
    public let navigationController: UINavigationController

    private var popHandlers: [UIViewController: (() -> Void)] = [:]
    private var dismissHandler: (() -> Void)?
    private var presentedRouter: Router?

    public var topViewControllerSubject: PassthroughSubject<UIViewController, Never> = .init()

    public enum ModalChange {
        case presented(UIViewController)
        case dismissed
    }
    public var presentedViewControllerSubject: PassthroughSubject<ModalChange, Never> = .init()

    public init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController

        super.init()

        navigationController.delegate = self
        navigationController.navigationBar.prefersLargeTitles = true
    }

    public convenience init(rootViewController: UIViewController) {
        self.init(navigationController: UINavigationController(rootViewController: rootViewController))
    }
}

public extension Router {
    // MARK: Pushing
    func push(_ viewController: UIViewController, animated: Bool = true, popHandler: (() -> Void)? = nil) {
        popHandlers[viewController] = popHandler
        navigationController.pushViewController(viewController,
                                                animated: animated && !navigationController.viewControllers.isEmpty)
    }

    // MARK: Replacing root
    func replaceRoot(with viewController: UIViewController, popHandler: (() -> Void)? = nil) {
        for handler in popHandlers.values {
            handler()
        }
        navigationController.popToRootViewController(animated: false)
        popHandlers = [:]
        popHandlers[viewController] = popHandler
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            navigationController.viewControllers = [viewController]
            return
        }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.navigationController.viewControllers = [viewController]
        })
    }

    // MARK: Removing all
    func removeAll() {
        for handler in popHandlers.values {
            handler()
        }
        navigationController.popToRootViewController(animated: false)
        popHandlers = [:]
        navigationController.viewControllers = []
    }

    // MARK: Popping
    func pop() {
        // Don’t call pop handlers, because `popViewController` triggers `navigationController(_:didShow:)`
        navigationController.popViewController(animated: true)
    }

    func popToRoot() {
        if let poppedViewControllers = navigationController.popToRootViewController(animated: true) {
            // Call pop handlers, because `popToRootViewController` only triggers
            // `navigationController(_:didShow:)` for the top view controller
            poppedViewControllers.forEach(handlePop)
        }
    }

    func popToViewController(_ viewController: UIViewController) {
        if let poppedViewControllers = navigationController.popToViewController(viewController, animated: true) {
            // Call pop handlers, because `navigationController.popToViewController(_:)` only triggers
            // `navigationController(_:didShow:)` for the top view controller
            poppedViewControllers.forEach(handlePop)
        }
    }
}

public extension Router {
    // MARK: Presenting modals
    func presentModal(_ viewController: UIViewController, animated: Bool = true, presentationStyle: UIModalPresentationStyle = .fullScreen, dismissHandler: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = presentationStyle
        navigationController.present(viewController, animated: animated) { [weak self] in
            self?.dismissHandler = dismissHandler
            self?.presentedViewControllerSubject.send(
                .presented(viewController)
            )
        }
    }

    func presentModal(_ router: Router, animated: Bool = true, presentationStyle: UIModalPresentationStyle = .fullScreen, dismissHandler: (() -> Void)? = nil) {
        self.presentedRouter = router
        presentModal(router.navigationController, animated: animated, presentationStyle: presentationStyle, dismissHandler: dismissHandler)
    }

    // MARK: Dismissing modals
    func dismissModal(animated: Bool = true, completion: (() -> Void)? = nil) {
        presentedRouter?.handleAllPopAndDismissHandlers()
        presentedRouter = nil

        dismissHandler?()
        dismissHandler = nil

        let completionWrapper: () -> Void = { [weak self] in
            completion?()
            self?.presentedViewControllerSubject.send(.dismissed)
        }

        navigationController.dismiss(animated: animated, completion: completionWrapper)
    }
}

// MARK: - UINavigationControllerDelegate
extension Router: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        topViewControllerSubject.send(viewController)
        if let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(poppedViewController) {
            handlePop(for: poppedViewController)
        }
    }
}

private extension Router {
    // MARK: Pop handlers
    func handlePop(for viewController: UIViewController) {
        if let popHandler = popHandlers.removeValue(forKey: viewController) {
            popHandler()
        }
    }

    func handleAllPopAndDismissHandlers() {
        presentedRouter?.handleAllPopAndDismissHandlers()
        presentedRouter = nil

        dismissHandler?()
        dismissHandler = nil

        popHandlers.keys.forEach(handlePop)
    }
}

public extension Router {
    struct NavigationState {
        fileprivate weak var topViewController: UIViewController?
    }

    func popToNavigationState(_ previousNavigationState: NavigationState) {
        guard let topViewController = previousNavigationState.topViewController else { return }
        popToViewController(topViewController)
    }

    var currentNavigationState: NavigationState {
        return NavigationState(topViewController: navigationController.topViewController)
    }
}
