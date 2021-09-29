//
//  BootstrapCoordinator.swift
//  TiltUp_Example
//
//  Created by Jeremy Grenier on 8/13/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import UIKit

import TiltUp

final class BootstrapCoordinator: Coordinator {
    override required init(appCoordinator: AppCoordinating) {
        super.init(appCoordinator: appCoordinator)
    }

    override func start() {
        goToHome()
    }
}

// MARK: - Navigation
private extension BootstrapCoordinator {
    func goToHome() {
        let coordinator = HomeCoordinator(parent: self)
        coordinator.start()
    }
}
