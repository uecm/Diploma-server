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
    var link: String?
    
    init(_ name: String?) {
        self.name = name
        self.link = DocumentManager.linkForBook(named: name ?? "")
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("name", name)
        try json.set("link", link)
        
        return json
    }
    
    convenience init(json: JSON) throws {
        try self.init(json.get("name"))
    }
}
