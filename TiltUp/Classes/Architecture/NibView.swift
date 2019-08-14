//
//  NibView.swift
//  TiltUp
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import UIKit

public protocol NibView: AnyObject {
    static var nib: UINib { get }
    static func make() -> Self
}

extension NibView {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    static func make() -> Self {
        let views = nib.instantiate(withOwner: nil)

        guard let view = views.first as? Self else {
            fatalError("NibView: Unable to instantiate \(self).")
        }

        return view
    }
}
