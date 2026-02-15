import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Skylarks App Config Provider"])
    }

    app.get("hello") { req async -> String in
        "Hello, Config!"
    }

    try app.register(collection: ConfigurationController())
    try app.register(collection: FeatureFlagController())
}
