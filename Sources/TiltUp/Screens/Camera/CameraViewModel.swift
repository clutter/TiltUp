//
//  CameraViewModel.swift
//  Forklift
//
//  Created by Jeremy Grenier on 8/28/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import AVFoundation
import UIKit

public enum Camera {
    public struct Logger {
        let info: (String) -> Void
        let bug: (String) -> Void

        public init(info: @escaping (String) -> Void, bug: @escaping (String) -> Void) {
            self.info = info
            self.bug = bug
        }
    }

    public final class CoordinatorObservers {
        public var tappedCancel: (() -> Void)?
        public var capturedPhotos: (([PhotoCapture]) -> Void)?
    }

    final class ViewObservers {
        var pointOfInterestReset:(() -> Void)?
        var presentAlert: ((UIAlertController) -> Void)?
        var rotateInterface: ((AVCaptureVideoOrientation) -> Void)?
        var updateOverlayState: ((CameraOverlayView.State) -> Void)?
        var updatePreviewSession: ((AVCaptureSession) -> Void)?
        var willCapturePhotoAnimation: (() -> Void)?
        var didCapturePhotoAnimation: (() -> Void)?
    }
}

public final class CameraViewModel: NSObject {
    // MARK: Dependencies
    private let logger: Camera.Logger

    // MARK: Observers
    public let coordinatorObservers = Camera.CoordinatorObservers()
    let viewObservers = Camera.ViewObservers()

    // MARK: Attributes

    private enum SessionSetupResult {
        case pending
        case success
        case notAuthorized
        case configurationFailed
    }

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.clutter.camera_session")

    private var setupResult = SessionSetupResult.pending

    private var videoDeviceInput: AVCaptureDeviceInput!

    private lazy var photoOutput: AVCapturePhotoOutput = {
        let output = AVCapturePhotoOutput()
        output.maxPhotoQualityPrioritization = .quality
        return output
    }()

    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureDelegate]()

    private var photos = [PhotoCapture]()

    private var currentVideoOrientation = AVCaptureVideoOrientation.portrait {
        didSet {
            viewObservers.rotateInterface?(currentVideoOrientation)
        }
    }
    private let zoomScaleRange: ClosedRange<CGFloat> = 1...5

    private var flashMode = AVCaptureDevice.FlashMode.auto

    public struct Settings {
        public let numberOfPhotos: ClosedRange<Int>
        public let cameraPosition: CameraPosition

        public enum CameraPosition {
            case back
            case front
        }

        public init(numberOfPhotos: ClosedRange<Int>, cameraPosition: CameraPosition = .back) {
            self.numberOfPhotos = numberOfPhotos
            self.cameraPosition = cameraPosition
        }
    }
    private let settings: Settings

    public init(settings: Settings, logger: Camera.Logger) {
        self.settings = settings
        self.logger = logger

        super.init()

        fetchSetupResult()

        sessionQueue.async(execute: configureSession)

        updateVideoOrientationForDeviceOrientation()
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(wasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)

        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaChanged), name: .AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }

    func viewWillAppear() {
        sessionQueue.async(execute: startSession)
        viewObservers.rotateInterface?(currentVideoOrientation)
    }

    func viewWillDisappear() {
        sessionQueue.async(execute: stopSession)
    }

    private func fetchSetupResult() {
        #if targetEnvironment(simulator)
        setupResult = .pending
        #else
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break

        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if granted == false {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })

        case .restricted, .denied:
            setupResult = .notAuthorized

        @unknown default:
            setupResult = .notAuthorized
        }
        #endif
    }
}

// MARK: Session
private extension CameraViewModel {
    func configureSession() {
        #if !targetEnvironment(simulator)
        guard setupResult == .pending else { return }

        session.beginConfiguration()

        session.sessionPreset = .photo

        do {
            var defaultVideoDevice: AVCaptureDevice?

            switch settings.cameraPosition {
            case .back:
                if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                    defaultVideoDevice = dualCameraDevice
                } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    defaultVideoDevice = backCameraDevice
                }
            case .front:
                if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    defaultVideoDevice = frontCameraDevice
                }
            }
            guard let videoDevice = defaultVideoDevice else {
                logger.bug("Default video device is unavailable.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }

            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)

            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                logger.bug("Couldn't add video device input to the session.")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            logger.bug("Couldn't create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)

            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = false
        } else {
            logger.info("Could not add photo output to the session")
            setupResult = .configurationFailed
        }

        session.commitConfiguration()

        setupResult = .success
        resetFocus()

        viewObservers.updatePreviewSession?(session)
        #endif
    }

    func startSession() {
        switch setupResult {
        case .pending:
            logger.info("Camera session pending authorization")

        case .success:
            logger.info("Camera session start running")
            session.startRunning()

        case .notAuthorized:
            logger.info("Camera session isn't authorized")

            DispatchQueue.main.async {
                let message = "The app doesn’t have permission to use the camera. Please enable it in Settings."
                let alertController = UIAlertController(title: "Missing Permissions", message: message, preferredStyle: .alert)

                alertController.addAction(UIAlertAction(title: "Ignore", style: .cancel))

                alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
                    // swiftlint:disable:next force_unwrapping
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }))

                self.viewObservers.presentAlert?(alertController)
            }

        case .configurationFailed:
            logger.info("Camera session cannot capture media")

            DispatchQueue.main.async {
                let message = "There was an error setting up the camera."
                let alertController = UIAlertController(title: "Camera Error", message: message, preferredStyle: .alert)

                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))

                self.viewObservers.presentAlert?(alertController)
            }
        }
    }

    func stopSession() {
        guard setupResult == .success else { return }
        session.stopRunning()
    }

    @objc private func wasInterrupted() {
        logger.info("Camera session is interrupted: \(session.isInterrupted)")
    }

    @objc private func subjectAreaChanged() {
        resetFocus()
        viewObservers.pointOfInterestReset?()
    }
}

// MARK: Capture
private extension CameraViewModel {
    func captureMockPhoto() {
        guard let photoCapture = PhotoCapture.mock() else { return }
        photoCapturePrepared(photoCapture)
        viewObservers.didCapturePhotoAnimation?()
    }

    func captureLivePhoto() {
        if let photoOutputConnection = photoOutput.connection(with: .video) {
            photoOutputConnection.videoOrientation = currentVideoOrientation
        }

        var photoSettings = AVCapturePhotoSettings()
        if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(
                format: [AVVideoCodecKey: AVVideoCodecType.hevc]
            )
        }

        photoSettings.photoQualityPrioritization = .quality

        let previewWidth = 512
        let previewHeight = 512
        // Specify a preview image.
        if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty,
           let pixelFormat = photoSettings.__availablePreviewPhotoPixelFormatTypes.first
        {
            photoSettings.previewPhotoFormat = [
                kCVPixelBufferPixelFormatTypeKey: pixelFormat,
                kCVPixelBufferWidthKey: previewWidth,
                kCVPixelBufferHeightKey: previewHeight
            ] as [String: Any]
        }

        if videoDeviceInput.device.isFlashAvailable {
            photoSettings.flashMode = flashMode
        }

        photoSettings.isHighResolutionPhotoEnabled = true

        let photoCaptureDelegate = PhotoCaptureDelegate(
            uniqueID: photoSettings.uniqueID,
            orientation: currentVideoOrientation,
            willCapturePhotoAnimation: viewObservers.willCapturePhotoAnimation,
            completionHandler: capturePhotoCompletion,
            logger: logger
        )

        inProgressPhotoCaptureDelegates[photoSettings.uniqueID] = photoCaptureDelegate
        photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
    }

    func capturePhoto() {
        #if targetEnvironment(simulator)
        captureMockPhoto()
        #else
        captureLivePhoto()
        #endif
    }

    func capturePhotoCompletion(_ photoCaptureDelegate: PhotoCaptureDelegate) {
        resetFocus()

        if let photoCapture = photoCaptureDelegate.photoCapture {
            photoCapturePrepared(photoCapture)
        }

        // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
        sessionQueue.async {
            self.inProgressPhotoCaptureDelegates[photoCaptureDelegate.uniqueID] = nil
        }

        viewObservers.didCapturePhotoAnimation?()
    }

    func photoCapturePrepared(_ photoCapture: PhotoCapture) {
        var remainingPhotoType: CameraOverlayView.RemainingPhotoType = .none
        let photoCountIncludingCurrentPhoto = photos.count + 1
        if photoCountIncludingCurrentPhoto < settings.numberOfPhotos.upperBound {
            if photoCountIncludingCurrentPhoto >= settings.numberOfPhotos.lowerBound {
                remainingPhotoType = .optional
            } else {
                remainingPhotoType = .required
            }
        }

        viewObservers.updateOverlayState?(
            .confirm(
                photoCapture: photoCapture,
                remainingPhotoType: remainingPhotoType
            )
        )
    }
}

// MARK: - Camera
extension CameraViewModel {
    func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        struct Holder {
            static var initialScale: CGFloat = 0.0
        }

        guard setupResult == .success else { return }

        let device = videoDeviceInput.device

        switch pinch.state {
        case .began: Holder.initialScale = device.videoZoomFactor
        case .changed:
            let minAvailableZoomScale = device.minAvailableVideoZoomFactor
            let maxAvailableZoomScale = device.maxAvailableVideoZoomFactor
            let availableZoomScaleRange = minAvailableZoomScale...maxAvailableZoomScale
            let resolvedZoomScaleRange = zoomScaleRange.clamped(to: availableZoomScaleRange)

            let resolvedScale = max(resolvedZoomScaleRange.lowerBound, min(pinch.scale * Holder.initialScale, resolvedZoomScaleRange.upperBound))

            configCamera(device) {
                device.videoZoomFactor = resolvedScale
            }
        default:
            return
        }
    }

    func focusCamera(at devicePoint: CGPoint) {
        guard setupResult == .success else { return }

        let device = videoDeviceInput.device

        configCamera(device) {
            let focusMode: AVCaptureDevice.FocusMode = .autoFocus
            if device.isFocusPointOfInterestSupported, device.isFocusModeSupported(focusMode) {
                device.focusPointOfInterest = devicePoint
                device.focusMode = focusMode
            }

            let exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
            if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = devicePoint
                device.exposureMode = exposureMode
            }

            device.isSubjectAreaChangeMonitoringEnabled = true
        }
    }

    @objc private func deviceOrientationChanged(_ note: Notification) {
        updateVideoOrientationForDeviceOrientation()
    }

    private func updateVideoOrientationForDeviceOrientation() {
        switch UIDevice.current.orientation {
        case .portrait: currentVideoOrientation = .portrait
        case .portraitUpsideDown: currentVideoOrientation = .portraitUpsideDown
        case .landscapeLeft: currentVideoOrientation = .landscapeRight
        case .landscapeRight: currentVideoOrientation = .landscapeLeft
        default: break
        }
    }

    private func resetFocus() {
        guard setupResult == .success else { return }

        let device = videoDeviceInput.device
        let defaultDevicePoint = CGPoint(x: 0.5, y: 0.5)

        configCamera(device) {
            let focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
            if device.isFocusModeSupported(focusMode) {
                if device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = defaultDevicePoint
                }

                device.focusMode = focusMode
            }

            device.whiteBalanceMode = AVCaptureDevice.WhiteBalanceMode.continuousAutoWhiteBalance

            let exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
            if device.isExposureModeSupported(exposureMode) {
                if device.isExposurePointOfInterestSupported {
                    device.exposurePointOfInterest = defaultDevicePoint
                }

                device.exposureMode = exposureMode
            }

            device.isSubjectAreaChangeMonitoringEnabled = false
        }
    }

    private func configCamera(_ device: AVCaptureDevice?, _ config: @escaping () -> Void) {
        guard let device = device else { return }

        sessionQueue.async {
            do {
                try device.lockForConfiguration()
                config()
                device.unlockForConfiguration()
            } catch {}
        }
    }
}

// MARK: - CameraOverlayViewDelegate Protocol
extension CameraViewModel: CameraOverlayViewDelegate {
    func toggleFlashMode() {
        guard videoDeviceInput.device.hasFlash else { return }

        switch flashMode {
        case .auto: flashMode = .on
        case .off: flashMode = .auto
        case .on: flashMode = .auto
        @unknown default: flashMode = .auto
        }
    }

    func confirmPictures() {
        coordinatorObservers.capturedPhotos?(photos)
    }

    func takePicture() {
        viewObservers.updateOverlayState?(.capture)
        sessionQueue.async(execute: capturePhoto)
    }

    func cancelCamera() {
        coordinatorObservers.tappedCancel?()
    }

    func retakePicture() {
        viewObservers.updateOverlayState?(.start(count: photos.count, canComplete: photos.count >= settings.numberOfPhotos.lowerBound))
    }

    func usePicture(_ photoCapture: PhotoCapture, continueCapturing: Bool) {
        photos.append(photoCapture)

        if continueCapturing {
            viewObservers.updateOverlayState?(.start(count: photos.count, canComplete: photos.count >= settings.numberOfPhotos.lowerBound))
        } else {
            coordinatorObservers.capturedPhotos?(photos)
        }
    }
}
