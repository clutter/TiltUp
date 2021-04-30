//
//  BaseViewObservers.swift
//  TiltUp
//
//  Created by Michael Mattson on 3/2/21.
//

import UIKit

open class BaseViewObservers: BaseViewObserving {
    public var loadingState: ((LoadingState) -> Void)?
    public var presentAlert: ((UIAlertController) -> Void)?

    public init() {}
}
