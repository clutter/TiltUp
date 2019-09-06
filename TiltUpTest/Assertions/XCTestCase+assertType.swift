//
//  XCTestCase+assertType.swift
//  TiltUpTest
//
//  Created by Erik Strottmann on 3/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

public extension XCTestCase {
    func assertType<S: Any, T: Any>(of expression: @autoclosure () throws -> S,
                                    is type: @autoclosure () throws -> T.Type,
                                    message: @autoclosure () -> String = "",
                                    file: StaticString = #file,
                                    line: UInt = #line) {
        let value: S
        do {
            value = try expression()
        } catch {
            recordFailure(
                withDescription: #"assertType(of:is:) failed: threw error "\#(error)" - \#(message())"#,
                inFile: String(describing: file),
                atLine: Int(line),
                expected: false
            )
            return
        }

        guard value is T else {
            recordFailure(
                withDescription: #"assertType(of:is:) failed: ("\#(value)") is not of type ("\#(T.self)") - \#(message())"#,
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            return
        }
    }

    func assertType<S: Any, T: Any>(of expression: @autoclosure () throws -> S,
                                    isNot type: @autoclosure () throws -> T.Type,
                                    message: @autoclosure () -> String = "",
                                    file: StaticString = #file,
                                    line: UInt = #line) {
        let value: S
        do {
            value = try expression()
        } catch {
            recordFailure(
                withDescription: #"assertType(of:isNot:) failed: threw error "\#(error)" - \#(message())"#,
                inFile: String(describing: file),
                atLine: Int(line),
                expected: false
            )
            return
        }

        guard !(value is T) else {
            recordFailure(
                withDescription: #"assertType(of:isNot:) failed: ("\#(value)") is not of type ("\#(T.self)") - \#(message())"#,
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            return
        }
    }
}
