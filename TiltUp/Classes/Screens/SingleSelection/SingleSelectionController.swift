//
//  SingleSelectionController.swift
//  TiltUp
//
//  Created by Robert Manson on 9/11/17.
//  Copyright © 2017 Clutter Inc. All rights reserved.
//

import UIKit

public final class SingleSelectionController<Value: SingleSelectionableRow>: UITableViewController {
    let viewModel: SingleSelectionViewModel<Value>

    public init(viewModel: SingleSelectionViewModel<Value>) {
        self.viewModel = viewModel

        super.init(style: .plain)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()

        if navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(tappedCancelButton))
        }

        viewModel.viewObservers.navTitle = { [weak self] title in
            self?.navigationItem.title = title
        }

        viewModel.viewObservers.confirmButtonEnabled = { [weak self] enabled in
            self?.navigationItem.rightBarButtonItem?.isEnabled = enabled
        }

        viewModel.viewObservers.confirmButtonTitle = { [weak self] title in
            guard let self = self else { return }

            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.tappedConfirmButton))
        }

        viewModel.viewObservers.toolbarButtonTitle = { [weak self] title in
            guard let self = self else { return }

            let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(self.tappedToolbarButton))
            self.setToolbarItems([spacer, button, spacer], animated: false)
        }

        viewModel.viewObservers.toolbarHidden = { [weak self] hidden, animated in
            self?.navigationController?.setToolbarHidden(hidden, animated: animated)
        }

        viewModel.viewObservers.rowUpdated = { [weak self] indexPath in
            guard let cell = self?.tableView.cellForRow(at: indexPath) else { return }

            self?.configure(cell, at: indexPath)
        }

        if let selection = viewModel.selectedIndexPath {
            tableView.selectRow(at: selection, animated: false, scrollPosition: .middle)
        }

        viewModel.start()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.updateToolbarHidden(animated: animated)
    }

    // MARK: - UITableViewDataSource

    public override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.title(forSection: section)
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(inSection: section)
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueOrCreateCell(withStyle: .value1, reuseIdentifier: "SingleSelectionCell")
        configure(cell, at: indexPath)
        return cell
    }

    // MARK: - UITableViewDelegate

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectedRow(at: indexPath)
    }

    // MARK: - Actions

    @objc func tappedCancelButton() {
        viewModel.tappedCancelButton()
    }

    @objc func tappedConfirmButton() {
        viewModel.tappedConfirmButton()
    }

    @objc func tappedToolbarButton() {
        viewModel.tappedToolbarButton()
    }
}

// MARK: - Private helpers
private extension SingleSelectionController {
    func configure(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let row = viewModel.row(at: indexPath)

        cell.textLabel?.text = row.value.singleSelectionableRow.title
        cell.detailTextLabel?.text = row.value.singleSelectionableRow.subtitle

        if row.value.singleSelectionableRow.hasNextStep {
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = row.isSelected ? .checkmark : .none
        }
    }
}
