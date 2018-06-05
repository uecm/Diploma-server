//
//  DocumentFile.swift
//  App
//
//  Created by Egor Kisilev on 6/5/18.
//

import Vapor
import Fluent


final class DocumentFile: JSONConvertible {
    var name: String?
    var link: String?
    
    init(name: String?) {
        self.name = name
        self.link = Config.hostname + "/download/" + (name ?? "")
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("name", name)
        try json.set("link", link)
        return json
    }
    
    init(json: JSON) throws {
        fatalError("Init with JSON is not implemented")
    }
}


extension DocumentFile: ResponseRepresentable { }



