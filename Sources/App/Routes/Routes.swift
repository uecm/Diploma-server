import Vapor
import AuthProvider
import Fluent
import Foundation.NSFileManager

extension Droplet {
    func setupRoutes() throws {
        try setupUnauthenticatedRoutes()
        try setupPasswordProtectedRoutes()
        try setupTokenProtectedRoutes()
        try setupStudentRoutes()
        try setupTeacherRoutes()
        try setupSubjectRoutes()
        try setupTaskRoutes()
        try setupFileRoutes()
    }

    /// Sets up all routes that can be accessed
    /// without any authentication. This includes
    /// creating a new User.
    private func setupUnauthenticatedRoutes() throws {
        // a simple json example response
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        // a simple plaintext example response
        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        // create a new user
        //
        // POST /users
        // <json containing new user information>
        post("users") { req in
            // require that the request body be json
            guard let json = req.json else {
                throw Abort(.badRequest)
            }

            // initialize the name and email from
            // the request json
            let user = try User(json: json)

            // ensure no user with this email already exists
            guard try User.makeQuery().filter("email", user.email).first() == nil else {
                throw Abort(.badRequest, reason: "A user with that email already exists.")
            }

            // require a plaintext password is supplied
            guard let password = json["password"]?.string else {
                throw Abort(.badRequest)
            }

            // hash the password and set it on the user
            user.password = try self.hash.make(password.makeBytes()).makeString()

            // save and return the new user
            try user.save()
            return user
        }
    }

    /// Sets up all routes that can be accessed using
    /// username + password authentication.
    /// Since we want to minimize how often the username + password
    /// is sent, we will only use this form of authentication to
    /// log the user in.
    /// After the user is logged in, they will receive a token that
    /// they can use for further authentication.
    private func setupPasswordProtectedRoutes() throws {
        // creates a route group protected by the password middleware.
        // the User type can be passed to this middleware since it
        // conforms to PasswordAuthenticatable
        let password = grouped([
            PasswordAuthenticationMiddleware(User.self)
        ])

        // verifies the user has been authenticated using the password
        // middleware, then generates, saves, and returns a new access token.
        //
        // POST /login
        // Authorization: Basic <base64 email:password>
        password.post("login") { req in
            let user = try req.user()
            let token = try Token.generate(for: user)
            try token.save()
            return token
        }
    }

    /// Sets up all routes that can be accessed using
    /// the authentication token received during login.
    /// All of our secure routes will go here.
    private func setupTokenProtectedRoutes() throws {
        // creates a route group protected by the token middleware.
        // the User type can be passed to this middleware since it
        // conforms to TokenAuthenticatable
        let token = grouped([
            TokenAuthenticationMiddleware(User.self)
        ])

        // simply returns a greeting to the user that has been authed
        // using the token middleware.
        //
        // GET /me
        // Authorization: Bearer <token from /login>
        token.get("me") { req in
            let user = try req.user()
            return user
        }
    }
    
    private func setupFileRoutes() throws {
        
//        // Get a file by name
//        get("file", String.parameter) { (req) in
//            let filename = try req.parameters.next(String.self)
//            return DocumentFile(name: filename)
//        }

        
        // Download a file by path took from query
        get("file/download") { req in
            let json = req.json
            guard let path = json?["link"]?.string else { throw Abort.badRequest }
            do {
                return try Response(filePath: path)
            } catch {
                throw Abort(.notFound)
            }
        }
        
        // Get all the book names from Public/Books/ dir
        get("file/books") { req in
            return try DocumentManager.books().makeJSON()
        }
        
        // Upload a book
        post("file/book") { (req) -> ResponseRepresentable in
            guard
                let book = req.data["book"]?.bytes,
                let name = req.data["name"]?.string else {
                    throw Abort.badRequest
            }
            try DocumentManager.saveBook(book, name: name)
            return Response(status: .ok)
        }
        
        
    }
}
