//
//  Routes+Task.swift
//  App
//
//  Created by Egor Kisilev on 5/3/18.
//

import Vapor
import AuthProvider

extension Droplet {
    
    
    func setupTaskRoutes() throws {
        post("task") { (req) -> ResponseRepresentable in
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            
            let subjectId = json["subjectId"]
            let studentId = json["studentId"]
            let teacherId = json["teacherId"]
            
            guard let subject = try Subject.makeQuery().filter("id", subjectId).first() else {
                throw Abort(.badRequest, reason: "Subject with this id does not exist.")
            }
            
            guard let student = try Student.makeQuery().filter("id", studentId).first() else {
                throw Abort(.badRequest, reason: "Student with this id does not exist.")
            }
            
            guard let teacher = try Teacher.makeQuery().filter("id", teacherId).first() else {
                throw Abort(.badRequest, reason: "Teacher with this id does not exist.")
            }
            
            let task = try Task(json: json)
    
            task.subjectId = subject.id
            task.studentId = student.id
            task.teacherId = teacher.id
            
            try task.save()
            
            return task
        }
        
        
        //MARK: get all tasks
        get("task/all") { (req) -> ResponseRepresentable in
            return try Task.makeQuery().all().makeJSON()
        }
        
        
        //MARK: get all tasks for authorized user
        let token = grouped([ TokenAuthenticationMiddleware(User.self) ])
        token.get("task") { (req) -> ResponseRepresentable in
            let user = try req.user()
            
            let student = try Student.makeQuery().all().filter({ (s) -> Bool in
                s.profile.parentId == user.id
            }).first

            let tasks = try Task.makeQuery().all().filter({
                $0.studentId == student?.id
            })
            
            return try tasks.makeJSON()
        }
    }
    
}
