//
//  UnexpectedNilError.swift
//  TiltUpTest
//
//  Created by Erik Strottmann on 9/3/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

public struct UnexpectedNilError: Error {
    public let expectedType: Any.Type
    public let file: StaticString
    public let line: UInt

    public init(expectedType: Any.Type, file: StaticString, line: UInt) {
        self.expectedType = expectedType
        self.file = file
        self.line = line
    }
}

extension UnexpectedNilError: LocalizedError {
    public var errorDescription: String? {
        return "Unexpectedly found nil while unwrapping a value of type \(expectedType)? at \(file):\(line)."
    }
}
