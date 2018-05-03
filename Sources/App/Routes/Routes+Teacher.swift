//
//  Routes+Teacher.swift
//  App
//
//  Created by Egor Kisilev on 5/3/18.
//

import Vapor

extension Droplet {
    
    func setupTeacherRoutes() throws {
        post("teacher") { (req) -> ResponseRepresentable in
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
            
            let teacher = try Teacher(json: json)
            
            teacher.userId = user.id
            
            try teacher.save()
            
            return teacher
        }
        
        get("teacher") { (req) -> ResponseRepresentable in
            return try Teacher.makeQuery().all().makeJSON()
        }
    }
    
    
}
