//
//  CameraPreviewView.swift
//  TiltUp
//
//  Created by Jeremy Grenier on 10/17/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import AVFoundation
import UIKit

final class CameraPreviewView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check \(Self.self).layerClass implementation.")
        }
        return layer
    }

    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer.session
        }
        set {
            videoPreviewLayer.session = newValue
            videoPreviewLayer.connection?.videoOrientation = .portrait
        }
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
