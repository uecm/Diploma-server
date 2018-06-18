//
//  DocumentFile.swift
//  App
//
//  Created by Egor Kisilev on 6/5/18.
//

import Vapor
import Fluent

protocol DocumentFile: JSONConvertible, ResponseRepresentable {
    var name: String? { get set }
    var path: String? { get set }
    init(_ name: String?)
}



