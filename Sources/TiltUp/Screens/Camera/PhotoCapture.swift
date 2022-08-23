//
//  PhotoCapture.swift
//  TiltUp
//
//  Created by Robert Manson on 3/4/20.
//

import UIKit
import AVFoundation

public struct PhotoCapture {
    let photoCaptureConverter: PhotoCaptureImageConverter
    let orientation: AVCaptureVideoOrientation
    public let expectedCaptureDuration: Measurement<UnitDuration>
    public let actualCaptureDuration: Measurement<UnitDuration>

    static func mock() -> PhotoCapture? {
        let image = UIImage.make(color: UIColor.cyan, size: CGSize(width: 640, height: 640))

        return PhotoCapture(
            forStubbingWith: image,
            expectedCaptureDuration: .init(value: 0, unit: .seconds),
            actualCaptureDuration: .init(value: 0, unit: .seconds)
        )
    }

    init?(
        capture: AVCapturePhoto,
        orientation: AVCaptureVideoOrientation,
        expectedCaptureDuration: Measurement<UnitDuration>,
        actualCaptureDuration: Measurement<UnitDuration>
    ) {
        self.photoCaptureConverter = capture
        self.orientation = orientation
        self.expectedCaptureDuration = expectedCaptureDuration
        self.actualCaptureDuration = actualCaptureDuration
    }

    public func makeUIImage(scale: CGFloat) -> UIImage? {
        photoCaptureConverter.makeUIImage(orientation: orientation, scale: scale)
    }

    public func makePreviewUIImage() -> UIImage? {
        photoCaptureConverter.makePreviewUIImage(orientation: orientation)
    }
}

// MARK: - Stubbing Support

public extension PhotoCapture {
    init?(
        forStubbingWith image: UIImage,
        expectedCaptureDuration: Measurement<UnitDuration>,
        actualCaptureDuration: Measurement<UnitDuration>
    ) {
        self.photoCaptureConverter = MockPhotoCaptureImageConverter(uiImage: image)
        self.orientation = .portrait
        self.expectedCaptureDuration = expectedCaptureDuration
        self.actualCaptureDuration = actualCaptureDuration
    }
}


protocol PhotoCaptureImageConverter {
    func makeUIImage(orientation: AVCaptureVideoOrientation, scale: CGFloat) -> UIImage?
    func makePreviewUIImage(orientation: AVCaptureVideoOrientation) -> UIImage?
}

struct MockPhotoCaptureImageConverter: PhotoCaptureImageConverter {
    let uiImage: UIImage?

    func makeUIImage(orientation: AVCaptureVideoOrientation, scale: CGFloat) -> UIImage? {
        uiImage
    }

    func makePreviewUIImage(orientation: AVCaptureVideoOrientation) -> UIImage? {
        uiImage
    }
}

extension AVCapturePhoto: PhotoCaptureImageConverter  {
    func makeUIImage(orientation: AVCaptureVideoOrientation, scale: CGFloat) -> UIImage? {
        guard let cgImage = self.cgImageRepresentation() else { return nil }

        let imageOrientation: UIImage.Orientation
        switch orientation {
        case .portrait:
            imageOrientation = .right
        case .portraitUpsideDown:
            imageOrientation = .left
        case .landscapeRight:
            imageOrientation = .up
        case .landscapeLeft:
            imageOrientation = .down
        @unknown default:
            imageOrientation = .right
        }

        return UIImage(
            cgImage: cgImage,
            scale: scale,
            orientation: imageOrientation
        )
    }

    func makePreviewUIImage(orientation: AVCaptureVideoOrientation) -> UIImage? {
        guard let cgImage = self.previewCGImageRepresentation() else { return nil }

        let imageOrientation: UIImage.Orientation
        switch orientation {
        case .portrait:
            imageOrientation = .right
        case .portraitUpsideDown:
            imageOrientation = .left
        case .landscapeRight:
            imageOrientation = .up
        case .landscapeLeft:
            imageOrientation = .down
        @unknown default:
            imageOrientation = .right
        }

        return UIImage(
            cgImage: cgImage,
            scale: 1,
            orientation: imageOrientation
        )
    }
}
