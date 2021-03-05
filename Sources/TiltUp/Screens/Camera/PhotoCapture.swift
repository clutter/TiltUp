//
//  PhotoCapture.swift
//  TiltUp
//
//  Created by Robert Manson on 3/4/20.
//

import UIKit
import AVFoundation

public struct PhotoCapture {
    public let fileDataRepresentation: Data
    public let expectedCaptureDuration: Measurement<UnitDuration>
    public let actualCaptureDuration: Measurement<UnitDuration>

    init?(
        capture: AVCapturePhoto,
        expectedCaptureDuration: Measurement<UnitDuration>,
        actualCaptureDuration: Measurement<UnitDuration>
    ) {
        guard let fileDataRepresentation = capture.fileDataRepresentation() else {
            return nil
        }
        self.fileDataRepresentation = fileDataRepresentation
        self.expectedCaptureDuration = expectedCaptureDuration
        self.actualCaptureDuration = actualCaptureDuration
    }
}

// MARK: - Stubbing Support

public extension PhotoCapture {
    init?(
        forStubbingWith image: UIImage,
        expectedCaptureDuration: Measurement<UnitDuration>,
        actualCaptureDuration: Measurement<UnitDuration>
    ) {
        guard let data = image.heicData(compressionQuality: 1.0) else {
            return nil
        }
        self.fileDataRepresentation = data
        self.expectedCaptureDuration = expectedCaptureDuration
        self.actualCaptureDuration = actualCaptureDuration
    }
}
