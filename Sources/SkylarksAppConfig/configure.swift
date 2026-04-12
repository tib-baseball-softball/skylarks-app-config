import Fluent
import FluentSQLiteDriver
import Leaf
import NIOSSL
import Vapor

public func configure(_ app: Application) async throws {
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET],
        allowedHeaders: [
            .accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent,
            .accessControlAllowOrigin,
        ],
        exposedHeaders: [
            .accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent,
            .accessControlAllowOrigin,
        ],
    )
    let cors = CORSMiddleware(configuration: corsConfiguration)
    
    // cors middleware should come before default error middleware using `at: .beginning`
    app.middleware.use(cors, at: .beginning)
    
    app.middleware.use(CSPMiddleware())
    app.middleware.use(BasicAuthPromptMiddleware(), at: .beginning)

    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateFirstSchema())

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
