//
//  Task.swift
//  App
//
//  Created by Egor Kisilev on 5/3/18.
//

import Vapor
import FluentProvider
import HTTP
import Foundation.NSJSONSerialization

final class Task: Model {
    enum TaskStatus: Int {
        case new = 0
        case inProgress = 1
        case pendingReview = 2
        case completed = 3
    }
    
    var storage = Storage()
    
    var description: String
    var startDate: Double
    var endDate: Double
    var status: Int
    var mark: Int
    var comment: String
    
    var subjectId: Identifier?
    var studentId: Identifier?
    var teacherId: Identifier?
    
    var subject: Parent<Task, Subject> {
        return parent(id: subjectId)
    }
    
    var student: Parent<Task, Student> {
        return parent(id: studentId)
    }
    
    var teacher: Parent<Task, Teacher> {
        return parent(id: teacherId)
    }
    
    var attachments: Children<Task, TaskAttachment> {
        return children()
    }
    
    /// Creates a new Subject
    init(description: String, startDate: Double, endDate: Double, status: Int, mark: Int, comment: String) {
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.comment = comment
        self.status = status
        self.mark = mark
    }
    
    
    // MARK: Row
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        description = try row.get("description")
        startDate = try row.get("startDate")
        endDate = try row.get("endDate")
        comment = try row.get("comment")
        status = try row.get("status")
        mark = try row.get("mark")
        
        subjectId = try row.get("subjectId")
        studentId = try row.get("studentId")
        teacherId = try row.get("teacherId")
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("description", description)
        try row.set("startDate", startDate)
        try row.set("endDate", endDate)
        try row.set("comment", comment)
        try row.set("status", status)
        try row .set("mark", mark)
        
        try row.set("teacherId", teacherId)
        try row.set("subjectId", subjectId)
        try row.set("studentId", studentId)

        return row
    }
}

// MARK: Preparation

extension Task: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Subjects
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.foreignId(for: Teacher.self, optional: false, unique: false, foreignIdKey: "teacherId", foreignKeyName: "id")
            builder.foreignId(for: Subject.self)
            builder.foreignId(for: Student.self)
            
            builder.string("description")
            builder.double("startDate")
            builder.double("endDate")
            builder.string("comment")
            builder.int("status")
            builder.int("mark")
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

extension Task: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            description: json.get("description"),
            startDate: json.get("startDate"),
            endDate: json.get("endDate"),
            status: json.get("status"),
            mark: json.get("mark"),
            comment: json.get("comment")
        )
        id = try json.get("id")
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("description", description)
        try json.set("startDate", startDate)
        try json.set("endDate", endDate)
        try json.set("comment", comment)
        try json.set("status", status)
        try json.set("mark", mark)
        
        let subject = try Subject.find(subjectId)
        try json.set("subject", subject?.makeJSON())
        
        let student = try Student.find(studentId)
        try json.set("student", student?.makeJSON())
        
        let teacher = try Teacher.find(teacherId)
        try json.set("teacher", teacher?.makeJSON())
    
        try json.set("attachments", attachments.all().makeJSON())
        
        return json
    }
}

// MARK: HTTP

// This allows User models to be returned
// directly in route closures
extension Task: ResponseRepresentable { }

