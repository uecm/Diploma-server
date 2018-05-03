//
//  Routes+Subject.swift
//  App
//
//  Created by Egor Kisilev on 5/3/18.
//

import Vapor

extension Droplet {
    
    func setupSubjectRoutes() throws {
        post("subject") { (req) -> ResponseRepresentable in
            guard let json = req.json else {
                throw Abort(.badRequest)
            }
            
            let subject = try Subject(json: json)
            
            try subject.save()
            
            return subject
        }
        
        get("subject") { (req) -> ResponseRepresentable in
            return try Subject.makeQuery().all().makeJSON()
        }
    }
}
