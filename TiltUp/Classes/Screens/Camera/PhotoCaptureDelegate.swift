//
//  PhotoCaptureDelegate.swift
//  TiltUp
//
//  Created by Jeremy Grenier on 10/17/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import AVFoundation

final class PhotoCaptureDelegate: NSObject {
    // MARK: Dependencies
    private let logger: Camera.Logger

    // MARK: Attributes

    let uniqueID: Int64
    private let willCapturePhotoAnimation: (() -> Void)?
    private let completionHandler: (PhotoCaptureDelegate) -> Void

    private(set) var photoData: Data?

    init(uniqueID: Int64,
         willCapturePhotoAnimation: (() -> Void)?,
         completionHandler: @escaping (PhotoCaptureDelegate) -> Void,
         logger: Camera.Logger) {

        self.uniqueID = uniqueID
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.completionHandler = completionHandler
        self.logger = logger
    }

    private func didFinish() {
        completionHandler(self)
    }
}

extension PhotoCaptureDelegate: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        willCapturePhotoAnimation?()
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            logger.bug("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if let error = error {
            logger.bug("Error capturing photo: \(error)")
            didFinish()
            return
        }

        guard let photoData = photoData else {
            logger.bug("No photo data resource")
            didFinish()
            return
        }

        self.photoData = photoData
        didFinish()
    }
}
