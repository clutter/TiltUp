//
//  HomeCoordinator.swift
//  TiltUp_Example
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
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

        viewModel.coordinatorObservers.goToCamera = { [weak self] in
            self?.goToCamera()
        }

        router.replaceRoot(with: controller, retaining: self)
    }

    func goToCamera() {
        let hintProvider: HintProvider = { numberOfPhotos in
            return "\(numberOfPhotos) Photos Captured"
        }

        let numberOfPhotos = 2...10
        let logger = Camera.Logger(info: { _ in }, bug: { _  in })
        let cameraViewModel = CameraViewModel(settings: .init(numberOfPhotos: numberOfPhotos), logger: logger)

        cameraViewModel.coordinatorObservers.tappedCancel = { [weak self] in
            guard let self = self else { return }
            self.router.dismissModal()
        }

        cameraViewModel.coordinatorObservers.capturedPhotos = { [weak self] photoCaptures in
            print("Captured \(photoCaptures.count) Photos")
            for (i, photoCapture) in photoCaptures.enumerated() {
                print(
                    """
                    Photo \(i):
                        Expected Duration: \(photoCapture.expectedCaptureDuration.converted(to: .seconds))
                        Actual Duration: \(photoCapture.actualCaptureDuration.converted(to: .seconds))
                    """
                )

                if let photoData = photoCapture.makeFileDataRepresentation(maxPixelSize: 1920) {
                    if let savedPhoto = SavedPhoto(data: photoData) {
                        print("Saved: \(savedPhoto.relativePath)")
                    } else {
                        print("Error saving photo")
                    }
                }
            }
            self?.router.dismissModal()
        }

        let coordinator = CameraCoordinator(
            parent: self,
            modal: true,
            hintProvider: hintProvider,
            viewModel: cameraViewModel
        )

        coordinator.start()
    }
}
