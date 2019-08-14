//
//  XCTestCase+assertType.swift
//  TiltUpTests
//
//  Created by Jeremy Grenier on 8/14/19.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

extension XCTestCase {
    func assertType<S: Any, T: Any>(of expression: @autoclosure () throws -> S, is type: @autoclosure () throws -> T.Type, message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        do {
            let value = try expression()
            guard value is T else {
                recordFailure(
                    withDescription: "assertType(of:is:) failed: (\"\(value)\") is not of type (\"\(T.self)\") - \(message())",
                    inFile: String(describing: file),
                    atLine: Int(line),
                    expected: true
                )
                return
            }
        } catch {
            recordFailure(
                withDescription: "assertType(of:is:) failed: threw error \"\(error)\" - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: false
            )
        }
    }

    func assertType<S: Any, T: Any>(of expression: @autoclosure () throws -> S, isNot type: @autoclosure () throws -> T.Type, message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
        do {
            let value = try expression()
            guard value is T else { return }
            recordFailure(
                withDescription: "assertType(of:isNot:) failed: (\"\(value)\") is of type (\"\(T.self)\") - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
        } catch {
            recordFailure(
                withDescription: "assertType(of:isNot:) failed: threw error \"\(error)\" - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: false
            )
        }
    }
}
