//
//  Student.swift
//  App
//
//  Created by Egor Kisilev on 4/23/18.
//

import Vapor
import FluentProvider
import AuthProvider
import HTTP


final class Student: Model {
    var storage = Storage()
    
    var userId: Identifier?

    var group: String
    
    var profile: Parent<Student, User> {
       return parent(id: userId)
    }
    
    /// Creates a new Student
    init(group: String) {
        self.group = group
    }
    
    // MARK: Row
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        group = try row.get("group")
        userId = try row.get("userId")
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("group", group)
        try row.set("userId", userId)
        return row
    }
}

// MARK: Preparation

extension Student: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Users
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: User.self)
            builder.string("group")
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

extension Student: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            group: json.get("group")
        )
        id = try json.get("id")
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("group", group)
        
        let user = try User.find(userId)
        try json.set("profile", user?.makeJSON())
        
        return json
    }
}

// MARK: HTTP

// This allows User models to be returned
// directly in route closures
extension Student: ResponseRepresentable { }



// MARK: Request

extension Request {
    /// Convenience on request for accessing
    /// this user type.
    /// Simply call `let user = try req.user()`.
//    func students() throws -> [Student] {
//        return try Student.makeQuery().all()
//    }
}


