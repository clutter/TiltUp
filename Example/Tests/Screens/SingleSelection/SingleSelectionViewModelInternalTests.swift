//
//  SingleSelectionViewModelInternalTests.swift
//  TiltUpTests
//
//  Created by Erik Strottmann on 10/17/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

@testable import TiltUp

final class SingleSelectionViewModelInternalTests: XCTestCase {
    func testInitializeWithRows() {
        let viewModel = SingleSelectionViewModel<TestRow>(rows: [.row1, .row2], navTitle: "Test")

        XCTAssertEqual(viewModel.numberOfSections, 1)

        XCTAssertNil(viewModel.title(forSection: 0))
        XCTAssertEqual(viewModel.numberOfRows(inSection: 0), 2)
        XCTAssertEqual(viewModel.row(at: IndexPath(row: 0, section: 0)).value.singleSelectionableRow.title, "row1")
        XCTAssertEqual(viewModel.row(at: IndexPath(row: 1, section: 0)).value.singleSelectionableRow.title, "row2")
    }

    func testInitializeWithSections() {
        let viewModel = SingleSelectionViewModel<TestRow>(sections: [
            (title: "Section 1", rows: [.row1, .row2]),
            (title: "Section 2", rows: [.row1, .row2])
        ], navTitle: "Sections")

        XCTAssertEqual(viewModel.numberOfSections, 2)

        XCTAssertEqual(viewModel.title(forSection: 0), "Section 1")
        XCTAssertEqual(viewModel.numberOfRows(inSection: 0), 2)
        XCTAssertEqual(viewModel.row(at: IndexPath(row: 0, section: 0)).value.singleSelectionableRow.title, "row1")
        XCTAssertEqual(viewModel.row(at: IndexPath(row: 1, section: 0)).value.singleSelectionableRow.title, "row2")

        XCTAssertEqual(viewModel.title(forSection: 1), "Section 2")
        XCTAssertEqual(viewModel.numberOfRows(inSection: 1), 2)
        XCTAssertEqual(viewModel.row(at: IndexPath(row: 0, section: 1)).value.singleSelectionableRow.title, "row1")
        XCTAssertEqual(viewModel.row(at: IndexPath(row: 1, section: 1)).value.singleSelectionableRow.title, "row2")
    }

    func testCheckmarks() {
        let viewModel = SingleSelectionViewModel<TestRow>(rows: [.row1, .row2], navTitle: "Test")

        var updatedIndexPaths: [IndexPath] = []
        viewModel.viewObservers.rowUpdated = { updatedIndexPaths.append($0) }

        // Select one row, making sure it’s checked
        viewModel.selectedRow(at: IndexPath(row: 0, section: 0))

        XCTAssertEqual(updatedIndexPaths, [IndexPath(row: 0, section: 0)])

        XCTAssertEqual(viewModel.row(at: IndexPath(row: 0, section: 0)).value.singleSelectionableRow.title, "row1")
        XCTAssertTrue(viewModel.row(at: IndexPath(row: 0, section: 0)).isSelected)
        XCTAssertFalse(viewModel.row(at: IndexPath(row: 1, section: 0)).isSelected)

        // Select another row, making sure the previous one is unchecked and the new one is checked
        updatedIndexPaths = []
        viewModel.selectedRow(at: IndexPath(row: 1, section: 0))

        XCTAssertEqual(updatedIndexPaths, [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)])

        XCTAssertFalse(viewModel.row(at: IndexPath(row: 0, section: 0)).isSelected)
        XCTAssertTrue(viewModel.row(at: IndexPath(row: 1, section: 0)).isSelected)
    }

    func testSelectAndConfirm() {
        let viewModel = SingleSelectionViewModel<TestRow>(rows: [.row1, .row2], navTitle: "Test")

        var confirmedRow: TestRow?
        viewModel.coordinatorObservers.tappedConfirm = { confirmedRow = $0 }

        var confirmButtonEnabled = false
        viewModel.viewObservers.confirmButtonEnabled = { confirmButtonEnabled = $0 }

        viewModel.selectedRow(at: IndexPath(row: 0, section: 0))
        XCTAssertNil(confirmedRow)
        XCTAssertTrue(confirmButtonEnabled)

        viewModel.tappedConfirmButton()
        XCTAssertEqual(confirmedRow, .row1)
    }
}

private enum TestRow: String, SingleSelectionableRow {
    case row1
    case row2

    var singleSelectionableRow: SingleSelection.Row {
        return SingleSelection.Row(title: rawValue, subtitle: nil, hasNextStep: false)
    }
}
