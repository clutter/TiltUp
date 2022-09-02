//
//  SavedPhoto.swift
//  TiltUp_Example
//
//  Created by Robert Manson on 9/1/22.
//  Copyright © 2022 Clutter. All rights reserved.
//

import Foundation

struct SavedPhoto {
    let fileExtension = ".heic"
    let relativePath: String
    let filename: String
    let fileURL: URL

    init?(data: Data) {
        filename = Self.makeFileName(fileExtension: fileExtension)
        let relativePath = "Photos" + "/" + filename
        self.relativePath = relativePath
        self.fileURL = Self.makeFileURL(with: relativePath)

        if !FileManager.default.createFile(atPath: fileURL.path, contents: data) {
            return nil
        }
    }

    static func makeFileName(fileExtension: String) -> String {
        return UUID().uuidString + fileExtension
    }

    static func makeFileURL(with relativePath: String) -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath: documentsPath)

        // Make photo directory
        let photoDirPath = documentsURL.appendingPathComponent("Photos", isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: photoDirPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Cannot create photo directory... catastrophe to follow")
        }

        return documentsURL.appendingPathComponent(relativePath)
    }
}
