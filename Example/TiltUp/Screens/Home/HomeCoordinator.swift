//
//  HomeCoordinator.swift
//  TiltUp_Example
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import TiltUp

final class HomeCoordinator: Coordinator {
    init(parent: Coordinating) {
        super.init(parent: parent, modal: false)
    }

    override func start() {
        goToHome()
    }
}

private extension HomeCoordinator {
    func goToHome() {
        let controller = HomeController.make()
        let viewModel = HomeViewModel()
        controller.viewModel = viewModel

        viewModel.coordinatorObservers.goToCamera = {
            let coordinator = CameraCoordinator(parent: self)
            coordinator.start()
        }

        // TODO: Set viewModel.coordinatorObservers

        // TODO: Decide whether to replaceRoot / push / present modally
        router.replaceRoot(with: controller, retaining: self)
    }
}
