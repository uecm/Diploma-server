//
//  Book.swift
//  App
//
//  Created by Egor Kisilev on 6/6/18.
//

import Vapor
import Fluent

final class Book: DocumentFile {
    var name: String?
    var path: String?
    
    init(_ name: String?) {
        self.name = name
        self.path = DocumentManager.pathForBook(named: name ?? "")
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("name", name)
        try json.set("path", path)
        
        return json
    }
    
    convenience init(json: JSON) throws {
        try self.init(json.get("name"))
    }
}
