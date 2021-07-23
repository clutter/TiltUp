//
//  CameraOverlayView.swift
//  TiltUp
//
//  Created by Jeremy Grenier on 8/8/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import AVFoundation
import UIKit

protocol CameraOverlayViewDelegate: AnyObject {
    func toggleFlashMode()
    func confirmPictures()
    func takePicture()
    func retakePicture()
    func usePicture(_ photoCapture: PhotoCapture, continueCapturing: Bool)
    func cancelCamera()
}

final class ShutterButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            layer.borderColor = UIColor.white.withAlphaComponent(isHighlighted ? 0.5 : 1.0).cgColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = bounds.width / 2
        layer.borderWidth = bounds.width * 0.05

        backgroundColor = UIColor.white.withAlphaComponent(0.5)
    }
}

final class CameraOverlayView: UIView {
    weak var delegate: CameraOverlayViewDelegate?

    /// Enum describing what photos still need to be captured this session
    enum RemainingPhotoType {
        /// No more photos are allowed to be captured this session
        case none
        /// There is at least one more required photo to be captured this session
        case required
        /// There are optional photos to be captured this session
        case optional
    }

    /// Current state of the camera
    enum State {
        /// The camera is ready to capture a photo, shutter button is visible as well as flash button
        /// - count: Number of photos that have been captured, is displayed on the overlay
        /// - canComplete: Bool indicating whether enough photos have been taken or not. When `true` the
        ///     finish button is visible
        case start(count: Int, canComplete: Bool)
        /// The camera is in the process of capturing a photo. The UI elements are hidden
        case capture
        /// The review stage for a photo that was taken, allows the user to accept the photo or retake it
        /// - photoCapture: The PhotoCapture object that represents the photo
        /// - remainingPhotoType: What type of photos still need to be captured this session, if any
        case confirm(photoCapture: PhotoCapture, remainingPhotoType: RemainingPhotoType)
    }

    private var hint: (_ numberOfPhotos: Int) -> String?

    var state = State.start(count: 0, canComplete: false) {
        didSet {
            switch state {
            case let .start(count, canComplete):
                cancelButton.isHidden = false
                countLabel.isHidden = count == 0
                countLabel.text = "\(count)"
                controlPanelFinishButton.isHidden = !canComplete
                flashButton.isHidden = false
                previewImageView.image = nil
                reviewButtonStack.isHidden = true
                shutterButton.isHidden = false
                landscapeSaveAndEndCaptureButton.isHidden = true
                landscapeRetakeButton.isHidden = true
                landscapeSaveAndCaptureMoreButton.isHidden = true

                hintLabel.text = hint(count)

            case .capture:
                cancelButton.isHidden = true
                countLabel.isHidden = true
                controlPanelFinishButton.isHidden = true
                flashButton.isHidden = true
                reviewButtonStack.isHidden = true
                shutterButton.isHidden = true
                landscapeSaveAndEndCaptureButton.isHidden = true
                landscapeRetakeButton.isHidden = true
                landscapeSaveAndCaptureMoreButton.isHidden = true
            case let .confirm(photoCapture, remainingPhotoType):
                cancelButton.isHidden = true
                countLabel.isHidden = true
                controlPanelFinishButton.isHidden = true
                flashButton.isHidden = true

                let image = UIImage(data: photoCapture.fileDataRepresentation)
                if let cgImage = image?.cgImage, let scale = image?.scale {
                    // Force the preview to display the photo as if it was taken as a portrait
                    // to prevent cropping in our imageview
                    // Camera is mounted at a 90 degree angle so portrait photos have the `.right` image orientation
                    previewImageView.image = UIImage(cgImage: cgImage, scale: scale, orientation: .right)
                } else {
                    previewImageView.image = image
                }

                UIView.performWithoutAnimation {
                    switch remainingPhotoType {
                    case .none:
                        saveAndCaptureMoreButton.setTitle("Finish", for: .normal)
                        Self.styleButton(saveAndCaptureMoreButton, outline: false, color: Self.tealColor)
                        saveAndEndCaptureButton.isHidden = true
                        landscapeSaveAndEndCaptureButton.isHidden = true
                    case .required:
                        saveAndCaptureMoreButton.setTitle("Next Photo", for: .normal)
                        Self.styleButton(saveAndCaptureMoreButton, outline: true, color: Self.tealColor)
                        saveAndEndCaptureButton.isHidden = true
                        landscapeSaveAndEndCaptureButton.isHidden = true
                    case .optional:
                        saveAndCaptureMoreButton.setTitle("Take More", for: .normal)
                        Self.styleButton(saveAndCaptureMoreButton, outline: true, color: Self.tealColor)
                        saveAndEndCaptureButton.isHidden = !(interfaceOrientation == .portrait || interfaceOrientation == .portraitUpsideDown)
                        landscapeSaveAndEndCaptureButton.isHidden = !(interfaceOrientation == .landscapeLeft || interfaceOrientation == .landscapeRight)
                    }
                    saveAndCaptureMoreButton.layoutIfNeeded()
                }
                reviewButtonStack.isHidden = false
                shutterButton.isHidden = true
            }

            if case .start = state {
                UIView.animate(withDuration: 0.3) {
                    self.animateRotation(to: self.interfaceOrientation)
                }
            } else {
                UIView.performWithoutAnimation {
                    self.animateRotation(to: self.interfaceOrientation)
                }
            }
        }
    }

    var interfaceOrientation = AVCaptureVideoOrientation.portrait {
        didSet {
            if case .confirm = state {
                return
            }

            UIView.animate(withDuration: 0.3) {
                self.animateRotation(to: self.interfaceOrientation)
            }
        }
    }

    // MARK: - Views

    private lazy var flashButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "flash_off"), for: .normal)
        button.setImage(UIImage(named: "flash_on"), for: .selected)
        button.alpha = 0.9
        button.addTarget(self, action: #selector(toggleFlashMode), for: .touchUpInside)
        controlPanelView.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44),
            button.centerYAnchor.constraint(equalTo: controlPanelView.centerYAnchor),
            NSLayoutConstraint(
                item: button,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: shutterButton,
                attribute: .leading,
                multiplier: 0.5,
                constant: 0.0
            )
        ])

        return button
    }()

    private lazy var countLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        label.textColor = .white
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor)
        ])

        return label
    }()

    private lazy var controlPanelFinishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Finish", for: .normal)
        button.setTitleColor(.init(white: 1.0, alpha: 0.9), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.isHidden = true
        button.addTarget(self, action: #selector(confirmPictures), for: .touchUpInside)
        controlPanelView.addSubview(button)

        let leadingSpace = shutterButton.trailingAnchor.anchorWithOffset(to: button.centerXAnchor)
        let trailingSpace = button.centerXAnchor.anchorWithOffset(to: controlPanelView.trailingAnchor)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 64),
            button.centerYAnchor.constraint(equalTo: controlPanelView.centerYAnchor),
            leadingSpace.constraint(equalTo: trailingSpace, multiplier: 1)
        ])

        return button
    }()

    private lazy var reviewButtonStack: UIStackView = {
        let innerStackView = UIStackView(arrangedSubviews: [
            retakeButton,
            saveAndCaptureMoreButton
        ])
        innerStackView.axis = .horizontal
        innerStackView.alignment = .center
        innerStackView.distribution = .fillEqually
        innerStackView.spacing = 16.0

        let outerStackView = UIStackView(arrangedSubviews: [
            innerStackView,
            saveAndEndCaptureButton
        ])

        outerStackView.axis = .vertical
        outerStackView.alignment = .fill
        outerStackView.spacing = 16
        outerStackView.isHidden = true

        addSubview(outerStackView)

        outerStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            outerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            outerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            outerStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16.0)
        ])

        return outerStackView
    }()

    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 64),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 3 / 4)
        ])

        return imageView
    }()

    private lazy var hintLabel: UILabel = {
        let container = UIView()
        container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(container)

        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        container.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10)
        ])

        return label
    }()

    private lazy var controlPanelView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 100),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        return view
    }()

    private lazy var shutterButton: UIButton = {
        let button = ShutterButton(type: .custom)
        button.addTarget(self, action: #selector(takePicture), for: .touchUpInside)
        controlPanelView.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalTo: controlPanelView.heightAnchor, multiplier: 0.8),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
            button.centerXAnchor.constraint(equalTo: controlPanelView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: controlPanelView.centerYAnchor)
        ])

        return button
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.init(white: 1.0, alpha: 0.9), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(cancelCamera), for: .touchUpInside)
        addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
            button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
        ])

        return button
    }()

    private lazy var retakeButton: UIButton = {
        Self.makeRetakeButton(target: self)
    }()

    private lazy var landscapeRetakeButton: UIButton = {
        let button = Self.makeRetakeButton(target: self)
        button.isHidden = true

        let halfHeightAnchor = button.centerYAnchor.anchorWithOffset(to: button.bottomAnchor)
        let leadingToCenterAnchor =  leadingAnchor.anchorWithOffset(to: button.centerXAnchor)

        let halfWidthAnchor = button.leadingAnchor.anchorWithOffset(to: button.centerXAnchor)
        let centerToTopAnchor = topAnchor.anchorWithOffset(to: button.centerYAnchor)

        addSubview(button)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            leadingToCenterAnchor.constraint(equalTo: halfHeightAnchor, constant: 16.0),
            centerToTopAnchor.constraint(equalTo: halfWidthAnchor, constant: 16.0)
        ])

        return button
    }()

    private lazy var saveAndCaptureMoreButton: UIButton = {
        Self.makeSaveAndCaptureMoreButton(target: self)
    }()

    private lazy var landscapeSaveAndCaptureMoreButton: UIButton = {
        let button = Self.makeSaveAndCaptureMoreButton(target: self)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        button.isHidden = true
        addSubview(button)

        button.centerXAnchor.anchorWithOffset(to: button.trailingAnchor)

        let halfHeightAnchor = button.centerYAnchor.anchorWithOffset(to: button.bottomAnchor)
        let leadingToCenterAnchor =  leadingAnchor.anchorWithOffset(to: button.centerXAnchor)

        let halfWidthAnchor = button.centerXAnchor.anchorWithOffset(to: button.trailingAnchor)
        let centerToBottomAnchor = button.centerYAnchor.anchorWithOffset(to: bottomAnchor)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            leadingToCenterAnchor.constraint(equalTo: halfHeightAnchor, constant: 16.0),
            centerToBottomAnchor.constraint(equalTo: halfWidthAnchor, constant: 16.0)
        ])

        return button
    }()

    private lazy var saveAndEndCaptureButton: UIButton = {
        Self.makeSaveAndEndCaptureButton(target: self)
    }()

    private lazy var landscapeSaveAndEndCaptureButton: UIButton = {
        let button = Self.makeSaveAndEndCaptureButton(target: self)
        button.isHidden = true

        addSubview(button)

        let halfHeightAnchor = button.centerYAnchor.anchorWithOffset(to: button.bottomAnchor)
        let centerToTrailingAnchor =  button.centerXAnchor.anchorWithOffset(to: trailingAnchor)

        let halfWidthAnchor = button.centerXAnchor.anchorWithOffset(to: button.trailingAnchor)
        let centerToBottomAnchor = button.centerYAnchor.anchorWithOffset(to: bottomAnchor)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            centerToTrailingAnchor.constraint(equalTo: halfHeightAnchor, constant: 16.0),
            centerToBottomAnchor.constraint(equalTo: halfWidthAnchor, constant: 16.0)
        ])

        return button
    }()

    private static func makeRetakeButton(target: Any?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Retake", for: .normal)
        button.setTitleColor(.init(white: 1.0, alpha: 0.9), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.addTarget(target, action: #selector(retakePicture), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        ])

        styleButton(button, outline: true, color: Self.warnLightColor)

        return button
    }

    private static func makeSaveAndCaptureMoreButton(target: Any?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Use Photo", for: .normal)
        button.setTitleColor(.init(white: 1.0, alpha: 0.9), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)

        button.addTarget(target, action: #selector(usePictureAndCaptureMoreIfPossible), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        ])

        styleButton(button, outline: true, color: Self.tealColor)

        return button
    }

    private static func makeSaveAndEndCaptureButton(target: Any?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Finish", for: .normal)
        button.setTitleColor(.init(white: 1.0, alpha: 0.9), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.isHidden = true
        button.addTarget(target, action: #selector(usePictureAndEndCapture), for: .touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        ])

        styleButton(button, outline: false, color: Self.tealColor)

        return button
    }

    required init(hint: @escaping (_ numberOfPhotos: Int) -> String?) {
        self.hint = hint

        super.init(frame: .zero)

        setUpViews()
        hintLabel.text = hint(0)
    }

    required init?(coder aDecoder: NSCoder) {
        hint = { _ in nil }

        super.init(coder: aDecoder)

        setUpViews()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        guard let superview = newSuperview else { return }
        frame = superview.bounds

        animateRotation(to: interfaceOrientation)
    }
}

extension CameraOverlayView {
    private func setUpViews() {
        backgroundColor = .clear

        _ = flashButton
        _ = controlPanelFinishButton
        _ = previewImageView
        _ = controlPanelView
        _ = cancelButton
        _ = shutterButton
        _ = reviewButtonStack
    }

    private func animateRotation(to orientation: AVCaptureVideoOrientation) {
        let transform: CGAffineTransform
        let hintSuperviewFrame: CGRect
        let atTop: Bool
        if case .confirm = state {
            atTop = true
        } else {
            atTop = false
        }

        let reviewButtonsHidden: Bool
        if case State.confirm = state {
            reviewButtonsHidden = false
        } else {
            reviewButtonsHidden = true
        }

        switch orientation {
        case .portrait:
            transform = .identity
            hintSuperviewFrame = CGRect(x: 0, y: atTop ? 0 : 64 + frame.width * 4 / 3 - 100, width: frame.width, height: 100)

            reviewButtonStack.isHidden = reviewButtonsHidden
            landscapeSaveAndEndCaptureButton.isHidden = true
            landscapeRetakeButton.isHidden = true
            landscapeSaveAndCaptureMoreButton.isHidden = true
        case .portraitUpsideDown:
            transform = CGAffineTransform.identity.rotated(by: 180 * .pi / 180)
            hintSuperviewFrame = CGRect(x: 0, y: atTop ? 0 : 64, width: frame.width, height: 100)
            reviewButtonStack.isHidden = reviewButtonsHidden
            landscapeSaveAndEndCaptureButton.isHidden = true
            landscapeRetakeButton.isHidden = true
            landscapeSaveAndCaptureMoreButton.isHidden = true
        case .landscapeRight:
            transform = CGAffineTransform.identity.rotated(by: 90 * .pi / 180)
            hintSuperviewFrame = CGRect(x: frame.width - 75, y: 64, width: 75, height: frame.width * 4 / 3)
            reviewButtonStack.isHidden = true
            landscapeRetakeButton.isHidden = reviewButtonsHidden
            landscapeSaveAndCaptureMoreButton.isHidden = reviewButtonsHidden
        case .landscapeLeft:
            transform = CGAffineTransform.identity.rotated(by: -90 * .pi / 180)
            hintSuperviewFrame = CGRect(x: 0, y: 64, width: 75, height: frame.width * 4 / 3)
            reviewButtonStack.isHidden = true
            landscapeRetakeButton.isHidden = reviewButtonsHidden
            landscapeSaveAndCaptureMoreButton.isHidden = reviewButtonsHidden
        @unknown default:
            return
        }

        hintLabel.superview?.transform = transform
        hintLabel.superview?.frame = hintSuperviewFrame
        flashButton.transform = transform
        controlPanelFinishButton.transform = transform
        cancelButton.transform = transform
        saveAndEndCaptureButton.transform = transform
        retakeButton.transform = transform
        saveAndCaptureMoreButton.transform = transform
        landscapeSaveAndEndCaptureButton.transform = transform
        landscapeRetakeButton.transform = transform
        landscapeSaveAndCaptureMoreButton.transform = transform
    }

    private static func styleButton(_ button: UIButton, outline: Bool, color: UIColor) {
        button.backgroundColor = outline ? .white : color
        button.setTitleColor(outline ? color : .white, for: .normal)
        button.layer.borderColor = outline ? color.cgColor : UIColor.white.cgColor

        button.layer.borderWidth = outline ? 1.0 : 0.0
        button.layer.cornerRadius = 8.0
        button.clipsToBounds = false

        button.titleLabel?.font = UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.semibold)

        button.titleEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: 16.0,
            bottom: 0.0,
            right: 16.0
        )
    }

    private static let tealColor = UIColor(red: 0.0, green: 0.631, blue: 0.604, alpha: 1.0)
    private static let warnLightColor = UIColor(red: 0.820, green: 0.588, blue: 0.082, alpha: 1.0)
}

private extension CameraOverlayView {
    @objc func toggleFlashMode() {
        flashButton.isSelected = !flashButton.isSelected
        delegate?.toggleFlashMode()
    }

    @objc func confirmPictures() {
        delegate?.confirmPictures()
    }

    @objc func takePicture() {
        delegate?.takePicture()
    }

    @objc func retakePicture() {
        delegate?.retakePicture()
    }

    @objc func usePictureAndCaptureMoreIfPossible() {
        guard case let .confirm(image, remainingPhotoType) = state else { return }
        switch remainingPhotoType {
        case .none:
            delegate?.usePicture(image, continueCapturing: false)
        case .required, .optional:
            delegate?.usePicture(image, continueCapturing: true)
        }
    }

    @objc func usePictureAndEndCapture() {
        guard case let .confirm(image, remainingPhotoType) = state else { return }
        switch remainingPhotoType {
        case .none, .optional:
            delegate?.usePicture(image, continueCapturing: false)
        case .required:
            return
        }
    }

    @objc func cancelCamera() {
        delegate?.cancelCamera()
    }
}
