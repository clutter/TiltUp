//
//  XCTIssue+make.swift
//  
//
//  Created by Robert Manson on 4/28/21.
//

import XCTest

public extension XCTIssue {
    static func make(
        _ description: String,
        inFile file: StaticString,
        atLine line: UInt
    ) -> XCTIssue {
        let location = XCTSourceCodeLocation(
            filePath: String(describing: file),
            lineNumber: Int(line)
        )
        let context = XCTSourceCodeContext(location: location)

        return XCTIssue(
            type: .assertionFailure,
            compactDescription: description,
            sourceCodeContext: context
        )
    }
}
