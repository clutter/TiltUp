//
//  PhotoCapture.swift
//  TiltUp
//
//  Created by Robert Manson on 3/4/20.
//

import Foundation
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
