//
//  Routes+Student.swift
//  App
//
//  Created by Egor Kisilev on 5/3/18.
//

import Vapor

extension Droplet {
    
    func setupStudentRoutes() throws {
        post("student") { (req) -> ResponseRepresentable in
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            
            let user = try User(json: json)
            
            guard try User.makeQuery().filter("email", user.email).first() == nil else {
                throw Abort(.badRequest, reason: "A user with that email already exists.")
            }
            
            guard let password = json["password"]?.string else {
                throw Abort(.badRequest)
            }
            
            user.password = try self.hash.make(password.makeBytes()).makeString()
            try user.save()
            
            let student = try Student(json: json)
            
            student.userId = user.id
            
            try student.save()
            
            return student
        }
        
        get("student") { (req) -> ResponseRepresentable in
            return try Student.makeQuery().all().makeJSON()
        }
    }
    
}
