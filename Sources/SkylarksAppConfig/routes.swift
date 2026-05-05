import Fluent
import Vapor

func routes(_ app: Application) throws {
    let protected = app.grouped(UserAuthenticator())
        .grouped(User.guardMiddleware())
        
    protected.get { req async throws in
        try await req.view.render("index", ["title": "Skylarks App Config Provider"])
    }
    
    app.get("api", "v1", "health") { req in
        return HealthCheck(message: "API available")
    }

    try app.register(collection: ConfigurationController())
    try app.register(collection: FeatureFlagController())
}

struct HealthCheck: Content {
    let message: String
}