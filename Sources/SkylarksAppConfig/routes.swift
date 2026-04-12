import Fluent
import Vapor

func routes(_ app: Application) throws {
    let protected = app.grouped(UserAuthenticator())
        .grouped(User.guardMiddleware())
        
    protected.get { req async throws in
        try await req.view.render("index", ["title": "Skylarks App Config Provider"])
    }

    try app.register(collection: ConfigurationController())
    try app.register(collection: FeatureFlagController())
}
