//
//  CameraCoordinator.swift
//  TiltUp_Example
//
//  Created by Robert Manson on 12/23/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import Foundation
import UIKit
import TiltUp

final class CameraCoordinator: Coordinator {
    init(parent: Coordinating) {
        super.init(parent: parent, modal: false)
    }

    override func start() {
        goToCamera()
    }
}

private extension CameraCoordinator {
    func goToCamera() {
        let numberOfPhotos = 2...10
        let logger = Camera.Logger(info: { _ in }, bug: { _  in })
        let viewModel = CameraViewModel(settings: .init(numberOfPhotos: numberOfPhotos), logger: logger)
        viewModel.coordinatorObservers.tappedCancel = { [weak self] in
            guard let self = self else { return }
            self.router.dismissModal()
        }
        viewModel.coordinatorObservers.capturedPhotos = { photoCaptures in
            print("Captured \(photoCaptures.count) Photos")
            for (i, photoCapture) in photoCaptures.enumerated() {
                print(
                    """
                    Photo \(i):
                        Expected Duration: \(photoCapture.expectedCaptureDuration.converted(to: .seconds))
                        Actual Duration: \(photoCapture.actualCaptureDuration.converted(to: .seconds))
                    """
                )
            }
        }

        let cameraController = CameraController(viewModel: viewModel, hint: { numberOfPhotos in
            return "\(numberOfPhotos) Photos Captured"
        })

        router.presentModal(cameraController, retaining: self)
    }
}
