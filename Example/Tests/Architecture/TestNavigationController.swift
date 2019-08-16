//
//  TestNavigationController.swift
//  TiltUpTests
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import UIKit

/// Subclass of UINavigationController that suppresses animations.
final class TestNavigationController: UINavigationController {
    var pushViewControllerCallCount = 0
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushViewControllerCallCount += 1
        super.pushViewController(viewController, animated: false)
    }

    var popViewControllerCallCount = 0
    override func popViewController(animated: Bool) -> UIViewController? {
        popViewControllerCallCount += 1
        return super.popViewController(animated: false)
    }

    var popToRootViewControllerCallCount = 0
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        popToRootViewControllerCallCount += 1
        return super.popToRootViewController(animated: false)
    }

    var popToViewControllerCallCount = 0
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        popToViewControllerCallCount += 1
        return super.popToViewController(viewController, animated: false)
    }

    var presentCallCount = 0
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        presentCallCount += 1
        super.present(viewControllerToPresent, animated: false, completion: completion)
    }

    var dismissCallCount = 0
    var dismissCompletionHandler: (() -> Void)?
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissCallCount += 1
        let dismissCompletion: (() -> Void)? = { [weak self] in
            completion?()
            self?.dismissCompletionHandler?()
        }
        super.dismiss(animated: false, completion: dismissCompletion)
    }
}
