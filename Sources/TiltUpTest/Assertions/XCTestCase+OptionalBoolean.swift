//
//  XCTestCase+OptionalBoolean.swift
//  TiltUpTest
//
//  Created by Sean Machen on 10/12/18.
//  Copyright © 2019 Clutter. All rights reserved.
//

import XCTest

public extension XCTestCase {
    func assertTrue(_ expression: @autoclosure () throws -> Bool?,
                    message: @autoclosure () -> String = "",
                    file: StaticString = #file,
                    line: UInt = #line) {
        let value: Bool?
        do {
            value = try expression()
        } catch {
            recordFailure(
                withDescription: #"assertTrue failed: threw error "\#(error)" - \#(message())"#,
                inFile: String(describing: file),
                atLine: Int(line),
                expected: false
            )
            return
        }

        guard let unwrapped = value else {
            recordFailure(
                withDescription: "assertTrue failed: found nil instead of a value of type \(Bool.self) - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            return
        }

        guard unwrapped == true else {
            recordFailure(
                withDescription: "assertTrue failed - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            return
        }
    }

    func assertFalse(_ expression: @autoclosure () throws -> Bool?,
                     message: @autoclosure () -> String = "",
                     file: StaticString = #file,
                     line: UInt = #line) {
        let value: Bool?
        do {
            value = try expression()
        } catch {
            recordFailure(
                withDescription: #"assertFalse failed: threw error "\#(error)" - \#(message())"#,
                inFile: String(describing: file),
                atLine: Int(line),
                expected: false
            )
            return
        }

        guard let unwrapped = value else {
            recordFailure(
                withDescription: "assertFalse failed: found nil instead of a value of type \(Bool.self) - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            return
        }

        guard unwrapped == false else {
            recordFailure(
                withDescription: "assertFalse failed - \(message())",
                inFile: String(describing: file),
                atLine: Int(line),
                expected: true
            )
            return
        }
    }
}
