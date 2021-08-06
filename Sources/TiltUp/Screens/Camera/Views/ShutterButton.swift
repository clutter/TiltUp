//
//  ShutterButton.swift
//  TiltUp
//
//  Created by Robert Manson on 8/2/21.
//

import UIKit

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
