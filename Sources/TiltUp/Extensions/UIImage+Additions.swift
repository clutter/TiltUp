//
//  UIImage+Additions.swift
//  TiltUp
//
//  Created by Robert Manson on 11/9/15.
//  Copyright © 2015 Clutter Inc. All rights reserved.
//

import AVFoundation
import CoreImage
import UIKit

// MARK: - Scaling and HEIC data
public extension UIImage {
    private static let sharedContext = CIContext(options: [.useSoftwareRenderer: false])

    @available(*, deprecated, renamed: "scaled(toFit:)")
    func scaled(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func scaled(toFit size: CGSize) -> UIImage? {
        guard let ciImage = CIImage(image: self) else {
            return nil
        }

        let newSize = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(origin: .zero, size: size))
        let scale = newSize.width / self.size.width

        let filter = CIFilter(name: "CILanczosScaleTransform")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(scale, forKey: kCIInputScaleKey)
        filter?.setValue(1.0, forKey: kCIInputAspectRatioKey)

        let orientation: CGImagePropertyOrientation
        switch imageOrientation {
        case .right, .rightMirrored:
            orientation = .right
        case .left, .leftMirrored:
            orientation = .left
        case .up, .upMirrored:
            orientation = .up
        case .down, .downMirrored:
            orientation = .down
        @unknown default:
            orientation = .right
        }

        guard
            let outputCIImage = filter?.outputImage?.oriented(orientation),
            let outputCGImage = UIImage.sharedContext.createCGImage(outputCIImage, from: outputCIImage.extent)
            else { return nil }

        return UIImage(cgImage: outputCGImage)
    }

    func heicData(compressionQuality: CGFloat) -> Data? {
        let data = NSMutableData()
        guard
            let destination = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil),
            let cgImage = cgImage
            else { return nil }

        let options = [kCGImageDestinationLossyCompressionQuality: compressionQuality]
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
        CGImageDestinationFinalize(destination)

        return data as Data
    }
}

// MARK: - Image from color
public extension UIImage {
    static func make(color: UIColor, size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
