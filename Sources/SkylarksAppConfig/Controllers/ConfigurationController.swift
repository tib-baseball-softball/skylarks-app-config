import Fluent
import Vapor

struct ConfigurationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let configs = routes.grouped("configs")

        configs.get(use: self.index)
        configs.get("form", use: self.form)
        configs.post("create", use: self.create)
        configs.group(":configurationID") { config in
            config.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> View {
        let configs = try await Configuration.query(on: req.db).all().map { $0.toDTO() }

        struct ConfigsResponse: Encodable {
            var title: String
            var configs: [ConfigurationDTO]
        }

        return try await req.view.render(
            "configs/list",
            ConfigsResponse(
                title: "Configurations List",
                configs: configs
            ))
    }

    @Sendable
    func form(req: Request) async throws -> View {
        return try await req.view.render(
            "configs/form",
            ["title:": "Configuration Form"]
        )
    }

    @Sendable
    func create(req: Request) async throws -> Response {
        let config = try req.content.decode(ConfigurationDTO.self).toModel()

        try await config.save(on: req.db)
        return req.redirect(to: "/configs")
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let config = try await Configuration.find(req.parameters.get("configID"), on: req.db)
        else {
            throw Abort(.notFound)
        }

        try await config.delete(on: req.db)
        return .noContent
    }
}
