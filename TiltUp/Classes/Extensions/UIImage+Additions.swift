//
//  UIImage+Additions.swift
//  TiltUp
//
//  Created by Robert Manson on 11/9/15.
//  Copyright © 2015 Clutter Inc. All rights reserved.
//

import AVFoundation
import UIKit

// MARK: - Scaling and HEIC data
public extension UIImage {
    func scaled(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
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
