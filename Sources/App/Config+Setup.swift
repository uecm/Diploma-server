import FluentProvider
import AuthProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {

        preparations.append(contentsOf: [
            User.self,
            Token.self,
            Student.self,
            Subject.self,
            Task.self,
            Teacher.self
        ])
    }
    
    
    static var hostname: String {
        let file = try! DataFile.read(at: "Config/server.json")
        let jsonObj = try! JSON(bytes: file)
        
        let hostname = try! jsonObj.get("hostname") as String
        let port = 8080
        return "\(hostname):\(port)"
    }
}
