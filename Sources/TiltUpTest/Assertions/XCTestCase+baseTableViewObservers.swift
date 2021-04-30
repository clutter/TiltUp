//
//  XCTestCase+baseTableViewObservers.swift
//  TiltUpTest
//
//  Created by Michael Mattson on 3/2/21.
//

import XCTest

import TiltUp

// MARK: - ViewObserver Testing Helpers
public extension XCTestCase {
    func waitForBaseTableViewObservers(_ viewObservers: BaseTableViewObserving, expectationTypes: [BaseTableViewObservers.ExpectationType], triggeringAction: (() -> Void)) {
        var viewObservers = viewObservers
        var expectations: [XCTestExpectation] = []

        if expectationTypes.contains(.presentAlert) {
            let presentedAlert = expectation(description: "Presented alert")
            viewObservers.presentAlert = { _ in presentedAlert.fulfill() }
            expectations.append(presentedAlert)
        }

        if expectationTypes.contains(.loadingCycle) {
            let showLoadingExpectation = expectation(description: "Showed loading")
            let hidLoadingExpectation = expectation(description: "Hid loading")

            viewObservers.loadingState = { loadingState in
                switch loadingState {
                case .notLoading:
                    hidLoadingExpectation.fulfill()
                case .loading:
                    showLoadingExpectation.fulfill()
                }
            }

            expectations.append(showLoadingExpectation)
            expectations.append(hidLoadingExpectation)
        }

        if expectationTypes.contains(.reloadData) {
            let reloadedData = expectation(description: "Reloaded data")
            viewObservers.reloadData = reloadedData.fulfill
            expectations.append(reloadedData)
        }

        triggeringAction()

        wait(for: expectations)

        if expectationTypes.contains(.presentAlert) { viewObservers.presentAlert = nil }
        if expectationTypes.contains(.loadingCycle) { viewObservers.loadingState = nil }
        if expectationTypes.contains(.reloadData) { viewObservers.reloadData = nil }
    }
}

extension BaseTableViewObservers {
    public enum ExpectationType {
        case presentAlert
        case loadingCycle
        case reloadData
    }
}
