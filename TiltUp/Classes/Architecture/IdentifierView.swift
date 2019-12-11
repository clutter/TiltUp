//
//  IdentifierView.swift
//  TiltUp
//
//  Created by Kevin Sylvestre on 2015-09-07.
//  Copyright © 2015 Clutter. All rights reserved.
//

import UIKit

protocol IdentifierView: AnyObject {
    static var identifier: String { get }
    static var nib: UINib { get }
}

extension IdentifierView {
    static var identifier: String {
        return String(describing: self)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle(for: self))
    }
}

// MARK: - UITableView

extension UITableView {
    func registerNib(for cellClass: (UITableViewCell & IdentifierView).Type) {
        register(cellClass.nib, forCellReuseIdentifier: cellClass.identifier)
    }

    func registerNibs(for cellClasses: [(UITableViewCell & IdentifierView).Type]) {
        cellClasses.forEach(registerNib)
    }

    func dequeue<Cell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell where Cell: UITableViewCell & IdentifierView {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: cellClass.identifier, for: indexPath) as! Cell
    }
}

extension UITableView {
    func dequeueOrCreateCell(withStyle style: UITableViewCell.CellStyle, reuseIdentifier: String) -> UITableViewCell {
        return dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: style, reuseIdentifier: reuseIdentifier)
    }
}

extension UITableView {
    func registerNib(forHeaderFooter viewClass: (UIView & IdentifierView).Type) {
        register(UINib(nibName: viewClass.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: viewClass.identifier)
    }

    func dequeueHeaderFooter<HeaderFooter>(_ viewClass: HeaderFooter.Type) -> HeaderFooter where HeaderFooter: UIView & IdentifierView {
        // swiftlint:disable:next force_cast
        return dequeueReusableHeaderFooterView(withIdentifier: viewClass.identifier) as! HeaderFooter
    }
}

// MARK: - UICollectionView

extension UICollectionView {
    func registerNib(for cellClass: (UICollectionViewCell & IdentifierView).Type) {
        register(cellClass.nib, forCellWithReuseIdentifier: cellClass.identifier)
    }

    func registerNibs(for cellClasses: [(UICollectionViewCell & IdentifierView).Type]) {
        cellClasses.forEach(registerNib)
    }

    func dequeue<Cell>(_ cellClass: Cell.Type, for indexPath: IndexPath) -> Cell where Cell: UICollectionViewCell & IdentifierView {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withReuseIdentifier: cellClass.identifier, for: indexPath) as! Cell
    }
}

extension UICollectionView {
    func registerNib(for viewClass: (UICollectionReusableView & IdentifierView).Type, forKind kind: String) {
        register(viewClass.nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: viewClass.identifier)
    }

    func dequeue<SupplementaryView>(_ viewClass: SupplementaryView.Type, forKind kind: String, for indexPath: IndexPath) -> SupplementaryView where SupplementaryView: UICollectionReusableView & IdentifierView {
        // swiftlint:disable:next force_cast
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewClass.identifier, for: indexPath) as! SupplementaryView
    }
}
