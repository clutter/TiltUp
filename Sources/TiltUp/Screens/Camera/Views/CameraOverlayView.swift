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
    func usePicture(_ photoCapture: PhotoCapture, canContinue: Bool)
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

    enum State {
        case start(count: Int, canComplete: Bool)
        case capture
        case confirm(photoCapture: PhotoCapture, canContinue: Bool)
    }

    private var hint: (_ numberOfPhotos: Int) -> String?

    var state = State.start(count: 0, canComplete: false) {
        didSet {
            switch state {
            case let .start(count, canComplete):
                cancelButton.isHidden = false
                countLabel.isHidden = count == 0
                countLabel.text = "\(count)"
                doneButton.isHidden = !canComplete
                flashButton.isHidden = false
                previewImageView.image = nil
                retakeButton.isHidden = true
                saveButton.isHidden = true
                shutterButton.isHidden = false

                hintLabel.text = hint(count)

            case .capture:
                cancelButton.isHidden = true
                countLabel.isHidden = true
                doneButton.isHidden = true
                flashButton.isHidden = true
                retakeButton.isHidden = true
                saveButton.isHidden = true
                shutterButton.isHidden = true

            case let .confirm(photoCapture, canContinue):
                cancelButton.isHidden = true
                countLabel.isHidden = true
                doneButton.isHidden = true
                flashButton.isHidden = true
                previewImageView.image = UIImage(data: photoCapture.fileDataRepresentation)
                retakeButton.isHidden = false
                saveButton.setTitle(canContinue ? "Continue" : "Use Photo", for: .normal)
                saveButton.isHidden = false
                shutterButton.isHidden = true
            }

            UIView.animate(withDuration: 0.3) {
                self.animateRotation(to: self.interfaceOrientation)
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

    private lazy var doneButton: UIButton = {
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
        let button = UIButton(type: .system)
        button.setTitle("Retake", for: .normal)
        button.setTitleColor(.init(white: 1.0, alpha: 0.9), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.isHidden = true
        button.addTarget(self, action: #selector(retakePicture), for: .touchUpInside)

        controlPanelView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: controlPanelView.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: controlPanelView.leadingAnchor, constant: 8)
        ])

        return button
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Use Photo", for: .normal)
        button.setTitleColor(.init(white: 1.0, alpha: 0.9), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.isHidden = true
        button.addTarget(self, action: #selector(usePicture), for: .touchUpInside)
        controlPanelView.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: controlPanelView.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: controlPanelView.trailingAnchor, constant: -8)
        ])

        return button
    }()

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
        _ = doneButton
        _ = previewImageView
        _ = controlPanelView
        _ = cancelButton
        _ = retakeButton
        _ = shutterButton
        _ = saveButton
    }

    private func animateRotation(to orientation: AVCaptureVideoOrientation) {
        let transform: CGAffineTransform
        let hintSuperviewFrame: CGRect

        switch orientation {
        case .portrait:
            transform = .identity
            hintSuperviewFrame = CGRect(x: 0, y: 64 + frame.width * 4 / 3 - 100, width: frame.width, height: 100)
        case .portraitUpsideDown:
            transform = CGAffineTransform.identity.rotated(by: 180 * .pi / 180)
            hintSuperviewFrame = CGRect(x: 0, y: 64, width: frame.width, height: 100)
        case .landscapeRight:
            transform = CGAffineTransform.identity.rotated(by: 90 * .pi / 180)
            hintSuperviewFrame = CGRect(x: 0, y: 64, width: 75, height: frame.width * 4 / 3)
        case .landscapeLeft:
            transform = CGAffineTransform.identity.rotated(by: -90 * .pi / 180)
            hintSuperviewFrame = CGRect(x: frame.width - 75, y: 64, width: 75, height: frame.width * 4 / 3)
        @unknown default:
            return
        }

        hintLabel.superview?.transform = transform
        hintLabel.superview?.frame = hintSuperviewFrame
        flashButton.transform = transform
        doneButton.transform = transform
        cancelButton.transform = transform
        retakeButton.transform = transform
        saveButton.transform = transform
    }
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

    @objc func usePicture() {
        guard case let .confirm(image, canContinue) = state else { return }
        delegate?.usePicture(image, canContinue: canContinue)
    }

    @objc func cancelCamera() {
        delegate?.cancelCamera()
    }
}
