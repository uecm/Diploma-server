//
//  Subject.swift
//  App
//
//  Created by Egor Kisilev on 5/3/18.
//

import Vapor
import FluentProvider
import HTTP


final class Subject: Model {
    var storage = Storage()
    
    var name: String
    
    /// Creates a new Subject
    init(name: String) {
        self.name = name
    }
    
    
    // MARK: Row
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        name = try row.get("name")
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
}

// MARK: Preparation

extension Subject: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Subjects
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new User (POST /users)
//

extension Subject: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name")
        )
        id = try json.get("id")
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
    
        return json
    }
}

// MARK: HTTP

// This allows User models to be returned
// directly in route closures
extension Subject: ResponseRepresentable { }

