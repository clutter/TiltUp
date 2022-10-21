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
    public let orientation: AVCaptureVideoOrientation
    public let expectedCaptureDuration: Measurement<UnitDuration>
    public let actualCaptureDuration: Measurement<UnitDuration>

    static func mock() -> PhotoCapture? {
        return PhotoCapture(
            forStubbingWith: nil,
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

    public func makeFileDataRepresentation(maxPixelSize: Int) -> Data? {
        photoCaptureConverter.makeFileDataRepresentation(
            orientation: orientation,
            maxPixelSize: maxPixelSize
        )
    }

    public func makePreviewUIImage() -> UIImage? {
        photoCaptureConverter.makePreviewUIImage(orientation: orientation)
    }
}

// MARK: - Stubbing Support

public extension PhotoCapture {
    static let stubImage = UIImage.make(color: UIColor.cyan, size: CGSize(width: 64, height: 64))

    init?(
        forStubbingWith image: UIImage?,
        expectedCaptureDuration: Measurement<UnitDuration>,
        actualCaptureDuration: Measurement<UnitDuration>
    ) {
        let image = image ?? PhotoCapture.stubImage
        self.photoCaptureConverter = MockPhotoCaptureImageConverter(uiImage: image)
        self.orientation = .portrait
        self.expectedCaptureDuration = expectedCaptureDuration
        self.actualCaptureDuration = actualCaptureDuration
    }
}


protocol PhotoCaptureImageConverter {
    func makeFileDataRepresentation(orientation: AVCaptureVideoOrientation, maxPixelSize: Int) -> Data?
    func makePreviewUIImage(orientation: AVCaptureVideoOrientation) -> UIImage?
}

extension PhotoCaptureImageConverter {
    static func fileDataRepresentation(
        for cgImage: CGImage,
        orientation: UInt32,
        maxPixelSize: Int
    ) -> Data? {
        let data = NSMutableData()
        guard
            let destination = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil)
            else { return nil }

        let options: [CFString: Any] = [
            kCGImageDestinationLossyCompressionQuality: 0.7,
            kCGImagePropertyOrientation: orientation,
            kCGImageDestinationImageMaxPixelSize: maxPixelSize
        ]

        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        CGImageDestinationFinalize(destination)

        return data as Data
    }
}

struct MockPhotoCaptureImageConverter: PhotoCaptureImageConverter {
    let uiImage: UIImage?

    func makeFileDataRepresentation(orientation: AVCaptureVideoOrientation, maxPixelSize: Int) -> Data? {
        uiImage?.jpegData(compressionQuality: 1.0)
    }

    func makePreviewUIImage(orientation: AVCaptureVideoOrientation) -> UIImage? {
        uiImage
    }
}

extension AVCapturePhoto: PhotoCaptureImageConverter  {
    func makeFileDataRepresentation(orientation: AVCaptureVideoOrientation, maxPixelSize: Int) -> Data? {
        guard let cgImage = self.cgImageRepresentation() else { return nil }

        let cgImageOrientation = metadata[String(kCGImagePropertyOrientation)] as? UInt32 ?? 1
        return Self.fileDataRepresentation(
            for: cgImage,
            orientation: cgImageOrientation,
            maxPixelSize: maxPixelSize
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
