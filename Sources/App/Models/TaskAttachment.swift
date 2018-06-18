//
//  TaskAttachment.swift
//  App
//
//  Created by Egor Kisilev on 6/18/18.
//

import Vapor
import FluentProvider
import AuthProvider
import HTTP
import Foundation.NSData

final class TaskAttachment: Model {
    var storage = Storage()
    
    var taskId: Identifier?
    
    var data: Bytes
    
    var task: Parent<TaskAttachment, Task> {
        return parent(id: taskId)
    }
    
    /// Creates a new Student
    init(data: Bytes) {
        self.data = data
    }
    
    // MARK: Row
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        taskId = try row.get("taskId")
        data = row["data"]?.bytes ?? []
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("data", StructuredData.bytes(data))
        try row.set("taskId", taskId)
        return row
    }
}

// MARK: Preparation

extension TaskAttachment: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Users
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: Task.self)
            builder.bytes("data")
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension TaskAttachment: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            data: json.get("data")
        )
        id = try json.get("id")
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("taskId", taskId)
        try json.set("data", StructuredData.bytes(self.data))

        return json
    }
}

extension TaskAttachment: ResponseRepresentable { }


