//
//  SingleSelectionViewModelTests.swift
//  TiltUpTests
//
//  Created by Jeremy Grenier on 4/25/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

import TiltUp

final class SingleSelectionViewModelTests: XCTestCase {
    func testInitializeWithRows() {
        _ = SingleSelectionViewModel<TestRow>(rows: [.row1, .row2], navTitle: "Test")
    }

    func testInitializeWithSections() {
        _ = SingleSelectionViewModel<TestRow>(sections: [
            (title: "Section 1", rows: [.row1, .row2]),
            (title: "Section 2", rows: [.row1, .row2])
        ], navTitle: "Sections")
    }

    func testCheckmarks() {
        let viewModel = SingleSelectionViewModel<TestRow>(rows: [.row1, .row2], navTitle: "Test")
        viewModel.preselectRow(at: IndexPath(row: 0, section: 0))
    }

    func testCancel() {
        let viewModel = SingleSelectionViewModel<TestRow>(rows: [.row1, .row2], navTitle: "Test")

        var cancelCalled = false
        viewModel.coordinatorObservers.tappedCancel = { cancelCalled = true }

        viewModel.tappedCancelButton()
        XCTAssertTrue(cancelCalled)
    }

    func testSelectAndConfirm() {
        let viewModel = SingleSelectionViewModel<TestRow>(rows: [.row1, .row2], navTitle: "Test")

        var confirmedRow: TestRow?
        viewModel.coordinatorObservers.tappedConfirm = { confirmedRow = $0 }

        viewModel.preselectRow(at: IndexPath(row: 0, section: 0))
        viewModel.tappedConfirmButton()
        XCTAssertEqual(confirmedRow, .row1)
    }

    func testToolbarButton() {
        let viewModel = SingleSelectionViewModel<TestRow>(rows: [.row1, .row2], navTitle: "Test", toolbarButtonTitle: "Toolbar!")

        var tappedToolbarButton = false
        viewModel.coordinatorObservers.tappedToolbarButton = { tappedToolbarButton = true }

        XCTAssertFalse(tappedToolbarButton)
        viewModel.tappedToolbarButton()
        XCTAssertTrue(tappedToolbarButton)
    }
}

private enum TestRow: String, SingleSelectionableRow {
    case row1
    case row2

    var singleSelectionableRow: SingleSelection.Row {
        return SingleSelection.Row(title: rawValue, subtitle: nil, hasNextStep: false)
    }
}
