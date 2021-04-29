//
//  XCTestCase+assertCast.swift
//  TiltUpTest
//
//  Created by Erik Strottmann on 3/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

public extension XCTestCase {
    func assertCast<S: Any, T: Any>(_ expression: @autoclosure () throws -> S,
                                    as type: @autoclosure () throws -> T.Type,
                                    message: @autoclosure () -> String = "",
                                    file: StaticString = #file,
                                    line: UInt = #line) throws -> T {
        let value: S?
        do {
            value = try expression()
        } catch {
            record(
                .make(
                    #"assertCast(_:as:) failed: threw error "\#(error)" - \#(message())"#,
                    inFile: file,
                    atLine: line
                )
            )
            throw error
        }

        guard let unwrapped = value else {
            record(
                .make(
                    "assertCast(_:as:) failed: found nil instead of a value of type \(T.self) - \(message())",
                    inFile: file,
                    atLine: line
                )
            )
            throw UnexpectedNilError(expectedType: T.self, file: file, line: line)
        }

        guard let cast = unwrapped as? T else {
            record(
                .make(
                    #"assertCast(_:as:) failed: ("\#(unwrapped)") is not of type ("\#(T.self)") - \#(message())"#,
                    inFile: file,
                    atLine: line
                )
            )
            throw UnexpectedNilError(expectedType: T.self, file: file, line: line)
        }

        return cast
    }
}
