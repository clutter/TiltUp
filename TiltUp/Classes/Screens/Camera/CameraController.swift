//
//  CameraController.swift
//  TiltUp
//
//  Created by Jeremy Grenier on 10/17/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import UIKit

public final class CameraController: UIViewController {
    private let previewView = CameraPreviewView()
    private let overlayView: CameraOverlayView

    private let generator = UIImpactFeedbackGenerator(style: .medium)

    public let viewModel: CameraViewModel

    public override var prefersStatusBarHidden: Bool { true }

    public init(viewModel: CameraViewModel, hint: String?) {
        self.viewModel = viewModel
        overlayView = CameraOverlayView(hint: { _ in hint })

        super.init(nibName: nil, bundle: nil)
    }

    public init(viewModel: CameraViewModel, hint: @escaping (_ numberOfPhotos: Int) -> String?) {
        self.viewModel = viewModel
        overlayView = CameraOverlayView(hint: hint)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black

        viewModel.viewObservers.presentAlert = { [weak self] alert in
            DispatchQueue.main.async {
                self?.present(alert, animated: true)
            }
        }

        viewModel.viewObservers.rotateInterface = { [weak self] orientation in
            DispatchQueue.main.async {
                self?.overlayView.interfaceOrientation = orientation
            }
        }

        viewModel.viewObservers.updateOverlayState = { [weak self] state in
            DispatchQueue.main.async {
                self?.overlayView.state = state
            }
        }

        viewModel.viewObservers.willCapturePhotoAnimation = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.generator.impactOccurred()
                self.previewView.videoPreviewLayer.opacity = 0
                UIView.animate(withDuration: 0.25) {
                    self.previewView.videoPreviewLayer.opacity = 1
                }
            }
        }

        previewView.session = viewModel.session

        view.addSubview(previewView)
        view.addSubview(overlayView)
        overlayView.delegate = viewModel

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        overlayView.addGestureRecognizer(pinch)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        overlayView.addGestureRecognizer(tap)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.viewWillAppear()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        viewModel.viewWillDisappear()
        super.viewWillDisappear(animated)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        previewView.frame = CGRect(x: 0.0, y: 64.0, width: view.bounds.width, height: view.bounds.width * 4 / 3)
        overlayView.frame = view.bounds
    }
}

extension CameraController {
    @objc private func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        viewModel.handlePinch(pinch)
    }

    @objc private func handleTap(_ tap: UITapGestureRecognizer) {
        let point = tap.location(in: previewView)

        guard point.x.isFinite && point.y.isFinite else { return }

        let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: point)

        focusAnimation(at: point)
        viewModel.focusCamera(at: devicePoint)
    }

    func focusAnimation(at point: CGPoint) {
        let focusView = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 70))
        focusView.layer.borderColor = UIColor(red: 0xFF / 0xFF, green: 0xB8 / 0xFF, blue: 0x18 / 0xFF, alpha: 1.0).cgColor
        focusView.layer.borderWidth = 1
        focusView.center = point
        focusView.alpha = 0.0
        previewView.subviews.forEach({ $0.removeFromSuperview() })
        previewView.addSubview(focusView)

        let appearAnimation = {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }

        let disappearAnimation = {
            focusView.alpha = 0.0
            focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
        }

        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: appearAnimation, completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: disappearAnimation) { _ in
                focusView.removeFromSuperview()
            }
        })
    }
}
