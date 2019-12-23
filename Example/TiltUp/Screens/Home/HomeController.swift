//
//  HomeController.swift
//  TiltUp_Example
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

import TiltUp

final class HomeController: UIViewController, StoryboardViewController {
    var viewModel: HomeViewModeling!

    override func viewDidLoad() {
        super.viewDidLoad()

        // TODO: Bind the Home.ViewObservers DO NOT STRONGLY CAPTURE SELF

        viewModel.start()
    }
    @IBAction func cameraButtonTapped(_ sender: Any) {
        viewModel.cameraButtonTapped()
    }
}
