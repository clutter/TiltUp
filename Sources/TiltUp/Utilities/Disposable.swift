//
//  Disposable.swift
//  TiltUp
//
//  Created by Michael Mattson on 9/23/19.
//

public final class Disposable {
    private let dispose: () -> Void

    public init(dispose: @escaping () -> Void) {
        self.dispose = dispose
    }

    deinit {
        dispose()
    }
}
