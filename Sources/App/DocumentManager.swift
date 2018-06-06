//
//  DocumentManager.swift
//  App
//
//  Created by Egor Kisilev on 6/6/18.
//

import Vapor
import Foundation.NSURL
import Foundation.NSFileManager

class DocumentManager {
    
    static let bookFolder = "Public/Books/"
    
    static func books() throws -> [Book] {
        return try FileManager.default.contentsOfDirectory(atPath: workingDirectory() + bookFolder)
                    .map(Book.init)
    }
    
    static func saveBook(_ bytes: Bytes, name: String) throws {
        let saveURL = URL(fileURLWithPath: workingDirectory())
            .appendingPathComponent(bookFolder, isDirectory: true)
            .appendingPathComponent(name, isDirectory: false)
        do {
            let fileData = Data(bytes: bytes)
            try fileData.write(to: saveURL)
        } catch { throw Abort.serverError }
    }
    
    static func linkForBook(named name: String) -> String {
        return bookFolder + name
    }
}

