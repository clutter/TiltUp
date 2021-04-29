//
//  XCTestCase+assertUnwrap.swift
//  TiltUpTest
//
//  Created by Erik Strottmann on 3/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

public extension XCTestCase {
    func assertUnwrap<T>(_ expression: @autoclosure () throws -> T?,
                         message: @autoclosure () -> String = "",
                         file: StaticString = #file,
                         line: UInt = #line) throws -> T {
        let value: T?
        do {
            value = try expression()
        } catch {
            recordFailure(
                withDescription: #"assertUnwrap failed: threw error "\#(error)" - \#(message())"#,
                inFile: String(describing: file),
                atLine: Int(line),
                expected: false
            )
            throw error
        }

        guard let unwrapped = value else {
            recordFailure(
                withDescription: "assertUnwrap failed: found nil instead of a value of type \(T.self) - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            throw UnexpectedNilError(expectedType: T.self, file: file, line: line)
        }

        return unwrapped
    }
}
