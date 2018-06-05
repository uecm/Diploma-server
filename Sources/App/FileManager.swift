//
//  FileManager.swift
//  App
//
//  Created by Egor Kisilev on 6/5/18.
//

import Vapor

class InternalFileManager {
    enum Error: Swift.Error {
        case couldNotOpenFile
        case unreadable
    }
    
    static func expandPath(_ path: String) throws -> String {
        let maybeResult = realpath(path, nil)
        
        guard let result = maybeResult else {
            throw Error.unreadable
        }
        
        defer { free(result) }
        
        let cstring = String(validatingUTF8: result)
        
        if let expanded = cstring {
            return expanded
        } else {
            throw Error.unreadable
        }
    }
    
    static func contentsOfDirectory(_ path: String) throws -> [String] {
        var gt = glob_t()
        defer { globfree(&gt) }
        
        let path = try self.expandPath(path).finished(with: "/")
        let pattern = strdup(path + "{*,.*}")
        defer { free(pattern) }
        
        switch glob(pattern, GLOB_MARK | GLOB_NOSORT | GLOB_BRACE, nil, &gt) {
        case GLOB_NOMATCH:
            return [ ]
        case GLOB_ABORTED:
            throw Error.unreadable
        default:
            break
        }
        
        var contents = [String]()
        let count: Int
        
        #if os(Linux)
        count = Int(gt.gl_pathc)
        #else
        count = Int(gt.gl_matchc)
        #endif
        
        for i in 0..<count {
            guard let utf8 = gt.gl_pathv[i] else { continue }
            let cstring = String(validatingUTF8: utf8)
            if let path = cstring {
                contents.append(path)
            }
        }
        
        return contents
    }
}
