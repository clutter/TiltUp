//
//  HomeViewModel.swift
//  TiltUp_Example
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import Foundation

enum Home {
    final class CoordinatorObservers {
        var goToCamera: (() -> Void)?
    }

    final class ViewObservers {
        // TODO: Define the actions that the ViewModel can call on the HomeController
    }
}

protocol HomeViewModeling {
    var coordinatorObservers: Home.CoordinatorObservers { get }
    var viewObservers: Home.ViewObservers { get }

    // TODO: Define the functions that HomeController can call on the viewModel
    func start()
    func cameraButtonTapped()
}

final class HomeViewModel: HomeViewModeling {
    // MARK: Dependencies
    // TODO: Define any dependencies that you use from the World here

    // MARK: Observers
    var coordinatorObservers = Home.CoordinatorObservers()
    var viewObservers = Home.ViewObservers()

    init() {
        // TODO: Any initial setup
    }

    func start() {
        // TODO: Setup that should be called once the HomeController has loaded
    }

    func cameraButtonTapped() {
        coordinatorObservers.goToCamera?()
    }
}
