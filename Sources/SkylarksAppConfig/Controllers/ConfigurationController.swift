import Fluent
import Vapor

struct ConfigurationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let todos = routes.grouped("todos")

        todos.get(use: self.index)
        todos.post(use: self.create)
        todos.group(":configurationID") { todo in
            todo.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [ConfigurationDTO] {
        try await Configuration.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> ConfigurationDTO {
        let todo = try req.content.decode(ConfigurationDTO.self).toModel()

        try await todo.save(on: req.db)
        return todo.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Configuration.find(req.parameters.get("configID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: req.db)
        return .noContent
    }
}
