//
//  BaseViewObserving.swift
//  TiltUp
//
//  Created by Michael Mattson on 3/2/21.
//

import UIKit

public typealias BaseViewObserving = LoadingStateObserving & PresentAlertObserving
public typealias BaseTableViewObserving = BaseViewObserving & ReloadDataObserving

public protocol ReloadDataObserving {
    var reloadData: (() -> Void)? { get set }
}

public protocol LoadingStateObserving {
    var loadingState: ((LoadingState) -> Void)? { get set }
}

public protocol PresentAlertObserving {
    var presentAlert: ((UIAlertController) -> Void)? { get set }
}

public enum LoadingState {
    case notLoading
    case loading(String = "Loading")
}
