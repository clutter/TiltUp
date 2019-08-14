//
//  StoryboardViewController.swift
//  TiltUp
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import UIKit

public protocol StoryboardViewController {
    static func make() -> Self
}

public extension StoryboardViewController {
    static func make() -> Self {
        let name = String(describing: self).replacingOccurrences(of: "Controller", with: "")
        let storyboard = UIStoryboard(name: name, bundle: nil)

        guard let controller = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("StoryboardViewController: unable to instantiate '\(self)'")
        }

        return controller
    }
}
