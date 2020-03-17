//
//  PhotoCaptureTests.swift
//  TiltUp_Tests
//
//  Created by Robert Manson on 3/16/20.
//  Copyright © 2020 Clutter. All rights reserved.
//

import XCTest
@testable import TiltUp

class PhotoCaptureTests: XCTestCase {
    var image: UIImage!
    let expectedCaptureDuration = Measurement<UnitDuration>(value: 10, unit: .seconds)
    let actualCaptureDuration = Measurement<UnitDuration>(value: 5, unit: .seconds)

    override func setUp() {
        self.image = UIImage.make(color: .red, size: CGSize(width: 200, height: 200))
    }

    override func tearDown() {
        self.image = nil
    }

    func testPhotoCaptureInit() throws {
        let capture = try assertUnwrap(
            PhotoCapture(
                forStubbingWith: image,
                expectedCaptureDuration: expectedCaptureDuration,
                actualCaptureDuration: actualCaptureDuration
            )
        )

        XCTAssertEqual(
            capture.fileDataRepresentation,
            image.heicData(compressionQuality: 1.0)
        )
        XCTAssertEqual(
            capture.expectedCaptureDuration,
            expectedCaptureDuration
        )
        XCTAssertEqual(
            capture.actualCaptureDuration,
            actualCaptureDuration
        )
    }
}