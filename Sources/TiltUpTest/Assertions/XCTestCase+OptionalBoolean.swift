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
            record(
                .make(
                    #"assertTrue failed: threw error "\#(error)" - \#(message())"#,
                    inFile: file,
                    atLine: line
                )
            )
            return
        }

        guard let unwrapped = value else {
            record(
                .make(
                    "assertTrue failed: found nil instead of a value of type \(Bool.self) - \(message())",
                    inFile: file,
                    atLine: line
                )
            )
            return
        }

        guard unwrapped == true else {
            record(
                .make(
                    "assertTrue failed - \(message())",
                    inFile: file,
                    atLine: line
                )
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
            record(
                .make(
                    #"assertFalse failed: threw error "\#(error)" - \#(message())"#,
                    inFile: file,
                    atLine: line
                )
            )
            return
        }

        guard let unwrapped = value else {
            record(
                .make(
                    "assertFalse failed: found nil instead of a value of type \(Bool.self) - \(message())",
                    inFile: file,
                    atLine: line
                )
            )
            return
        }

        guard unwrapped == false else {
            record(
                .make(
                    "assertFalse failed - \(message())",
                    inFile: file,
                    atLine: line
                )
            )
            return
        }
    }
}
