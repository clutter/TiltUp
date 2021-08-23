//
//  CameraCoordiantor.swift
//  TiltUp
//
//  Created by John Brophy on 8/17/21.
//  Copyright © 2021 Clutter. All rights reserved.
//

import Foundation

public final class CameraCoordinator: Coordinator {
    private let viewModel: CameraViewModel
    private let hintProvider: HintProvider

    public init(
        parent: Coordinating,
        modal: Bool,
        hintProvider: @escaping HintProvider,
        viewModel: CameraViewModel
    ) {
        self.hintProvider = hintProvider
        self.viewModel = viewModel
        super.init(parent: parent, modal: modal)
    }

    public override func start() {
        goToCamera()
    }
}

private extension CameraCoordinator {
    func goToCamera() {
        let controller = CameraController(viewModel: viewModel, hint: hintProvider)
        router.push(controller, retaining: self)

        if router != parent?.router {
            parent?.router.presentModal(router)
        }
    }
}
