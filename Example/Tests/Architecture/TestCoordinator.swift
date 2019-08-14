//
//  TestCoordinator.swift
//  TiltUpTests
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import TiltUp

class TestCoordinator: Coordinator {
    let testAppCoordinator: TestAppCoordinator

    init(testAppCoordinator: TestAppCoordinator = .init()) {
        self.testAppCoordinator = testAppCoordinator
        super.init(appCoordinator: testAppCoordinator)
    }
}
