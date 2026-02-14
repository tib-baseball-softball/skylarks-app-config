import NIOSSL
import Fluent
import FluentSQLiteDriver
import Leaf
import Vapor

public func configure(_ app: Application) async throws {
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateFirstSchema())

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
