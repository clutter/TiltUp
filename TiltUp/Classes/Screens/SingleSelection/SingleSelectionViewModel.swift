//
//  SingleSelectionViewModel.swift
//  TiltUp
//
//  Created by Robert Manson on 9/11/17.
//  Copyright © 2017 Clutter Inc. All rights reserved.
//

import UIKit

public enum SingleSelection {
    public struct Row: Equatable {
        public var title: String
        public var subtitle: String?
        public var hasNextStep: Bool

        public init(title: String, subtitle: String?, hasNextStep: Bool) {
            self.title = title
            self.subtitle = subtitle
            self.hasNextStep = hasNextStep
        }
    }

    public final class CoordinatorObservers<Value: SingleSelectionableRow> {
        public var tappedCancel: (() -> Void)?
        public var tappedConfirm: ((Value) -> Void)?
        public var tappedToolbarButton: (() -> Void)?
    }

    final class ViewObservers {
        var navTitle: ((String) -> Void)?
        var confirmButtonEnabled: ((Bool) -> Void)?
        var confirmButtonTitle: ((String) -> Void)?
        var toolbarHidden: ((Bool) -> Void)?
        var toolbarButtonTitle: ((String?) -> Void)?
        var rowUpdated: ((IndexPath) -> Void)?
    }
}

public protocol SingleSelectionableRow {
    var singleSelectionableRow: SingleSelection.Row { get }
}

public final class SingleSelectionViewModel<Value: SingleSelectionableRow> {
    // MARK: Observers
    public let coordinatorObservers = SingleSelection.CoordinatorObservers<Value>()
    let viewObservers = SingleSelection.ViewObservers()

    // MARK: Attributes

    struct Section {
        var title: String?
        var rows: [Row]
    }

    struct Row {
        var value: Value
        var isSelected: Bool
    }

    private var sections: [Section]
    private let hasSections: Bool
    private let navTitle: String
    private let toolbarButtonTitle: String?
    private let toolbarHidden: Bool

    // MARK: - Init

    public init(rows: [Value],
                navTitle: String,
                toolbarButtonTitle: String? = nil) {

        self.sections = [
            Section(title: nil, rows: rows.map { Row(value: $0, isSelected: false) })
        ]
        self.hasSections = false

        self.navTitle = navTitle
        self.toolbarHidden = toolbarButtonTitle == nil
        self.toolbarButtonTitle = toolbarButtonTitle
    }

    public init(sections: [(title: String?, rows: [Value])],
                navTitle: String,
                toolbarButtonTitle: String? = nil) {

        self.sections = sections.map { section in
            Section(title: section.title, rows: section.rows.map { Row(value: $0, isSelected: false) })
        }
        self.hasSections = true

        self.navTitle = navTitle
        self.toolbarHidden = toolbarButtonTitle == nil
        self.toolbarButtonTitle = toolbarButtonTitle
    }

    public func start() {
        viewObservers.navTitle?(navTitle)
        viewObservers.confirmButtonEnabled?(selectedIndexPath != nil)
        viewObservers.confirmButtonTitle?(confirmButtonTitle)
        viewObservers.toolbarHidden?(toolbarHidden)
        viewObservers.toolbarButtonTitle?(toolbarButtonTitle)
    }

    var selectedIndexPath: IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            if let rowIndex = section.rows.firstIndex(where: { $0.isSelected }) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }

    var confirmButtonTitle: String {
        guard let selectedIndexPath = selectedIndexPath else { return "Save" }
        let row = self.row(at: selectedIndexPath)
        return row.value.singleSelectionableRow.hasNextStep ? "Next" : "Save"
    }

    // MARK: - Table data

    var numberOfSections: Int {
        return hasSections ? sections.count : 1
    }

    func title(forSection section: Int) -> String? {
        guard hasSections else { return nil }
        return sections[section].title
    }

    func numberOfRows(inSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func row(at indexPath: IndexPath) -> SingleSelectionViewModel<Value>.Row {
        return sections[indexPath.section].rows[indexPath.row]
    }

    // MARK: - Actions

    public func selectedRow(at indexPath: IndexPath) {
        for (sectionIndex, section) in sections.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() where row.isSelected {
                sections[sectionIndex].rows[rowIndex].isSelected = false
                viewObservers.rowUpdated?(IndexPath(row: rowIndex, section: sectionIndex))
            }
        }
        sections[indexPath.section].rows[indexPath.row].isSelected = true
        viewObservers.rowUpdated?(indexPath)

        viewObservers.confirmButtonEnabled?(selectedIndexPath != nil)
        viewObservers.confirmButtonTitle?(confirmButtonTitle)

        let value = sections[indexPath.section].rows[indexPath.row].value
        if value.singleSelectionableRow.hasNextStep {
            coordinatorObservers.tappedConfirm?(value)
        }
    }

    public func tappedCancelButton() {
        coordinatorObservers.tappedCancel?()
    }

    public func tappedConfirmButton() {
        guard let selectedIndexPath = selectedIndexPath else { return }
        let row = sections[selectedIndexPath.section].rows[selectedIndexPath.row]
        coordinatorObservers.tappedConfirm?(row.value)
    }

    public func tappedToolbarButton() {
        coordinatorObservers.tappedToolbarButton?()
    }
}
