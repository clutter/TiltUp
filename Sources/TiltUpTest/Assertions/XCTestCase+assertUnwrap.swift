//
//  XCTestCase+assertUnwrap.swift
//  TiltUpTest
//
//  Created by Erik Strottmann on 3/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

public extension XCTestCase {
    func assertUnwrap<T>(
        _ expression: @autoclosure () throws -> T?,
        message: @autoclosure () -> String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T {
        let value: T?
        do {
            value = try expression()
        } catch {
            record(
                .make(
                    #"assertUnwrap failed: threw error "\#(error)" - \#(message())"#,
                    inFile: file,
                    atLine: line
                )
            )
            throw error
        }

        guard let unwrapped = value else {
            record(
                .make(
                    "assertUnwrap failed: found nil instead of a value of type \(T.self) - \(message())",
                    inFile: file,
                    atLine: line
                )
            )
            throw UnexpectedNilError(expectedType: T.self, file: file, line: line)
        }

        return unwrapped
    }
}
