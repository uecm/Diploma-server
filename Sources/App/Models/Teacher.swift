//
//  Teacher.swift
//  App
//
//  Created by Egor Kisilev on 5/3/18.
//

import Vapor
import FluentProvider
import AuthProvider
import HTTP

enum TeacherStatus: Int {
    case assistant = 1
    case teacher = 2
    case professor = 3
    case docent = 4
    case PhD = 5
    
    case none = 0
}


final class Teacher: Model {
    var storage = Storage()
    
    var userId: Identifier?
    
    var status: Int
    
    var profile: Parent<Teacher, User> {
        return parent(id: userId)
    }
    
    /// Creates a new Teacher
    init(status: Int) {
        self.status = status
    }
    
    
    // MARK: Row
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        status = try row.get("status")
        userId = try row.get("userId")
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("status", status)
        try row.set("userId", userId)
        return row
    }
}

// MARK: Preparation

extension Teacher: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Teachers
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: User.self)
            builder.int("status")
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

extension Teacher: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            status: json.get("status")
        )
        id = try json.get("id")
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("status", status)
        
        let user = try User.find(userId)
        try json.set("profile", user?.makeJSON())
        
        return json
    }
}

// MARK: HTTP

// This allows User models to be returned
// directly in route closures
extension Teacher: ResponseRepresentable { }


