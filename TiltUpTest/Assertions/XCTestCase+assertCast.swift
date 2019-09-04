//
//  XCTestCase+assertCast.swift
//  TiltUpTest
//
//  Created by Erik Strottmann on 3/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

extension XCTestCase {
    func assertCast<S: Any, T: Any>(_ expression: @autoclosure () throws -> S,
                                    as type: @autoclosure () throws -> T.Type,
                                    message: @autoclosure () -> String = "",
                                    file: StaticString = #file,
                                    line: UInt = #line) throws -> T {
        let value: S?
        do {
            value = try expression()
        } catch {
            recordFailure(
                withDescription: #"assertCast(_:as:) failed: threw error "\#(error)" - \#(message())"#,
                inFile: String(describing: file),
                atLine: Int(line),
                expected: false
            )
            throw error
        }

        guard let unwrapped = value else {
            recordFailure(
                withDescription: "assertCast(_:as:) failed: found nil instead of a value of type \(T.self) - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            throw UnexpectedNilError(expectedType: T.self, file: file, line: line)
        }

        guard let cast = unwrapped as? T else {
            recordFailure(
                withDescription: #"assertCast(_:as:) failed: ("\#(unwrapped)") is not of type ("\#(T.self)") - \#(message())"#,
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            throw UnexpectedNilError(expectedType: T.self, file: file, line: line)
        }

        return cast
    }
}
