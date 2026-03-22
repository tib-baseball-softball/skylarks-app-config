import Fluent
import Vapor

struct ConfigurationController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let configs = routes.grouped("configs")

        configs.get(use: self.index)
        configs.get("form", use: self.createForm)
        configs.post("create", use: self.create)
        configs.group(":id") { config in
            config.get(use: self.show)
            config.get("formUpdate", use: self.updateForm)
            config.post("update", use: self.update)
            config.post("delete", use: self.delete)
        }

        let api = routes.grouped("api")

        api.get("configs", use: self.apiList)
    }

    @Sendable
    func index(req: Request) async throws -> View {
        let configs = try await Configuration.query(on: req.db).with(\.$flagRelations) {
            $0.with(\.$flag)
        }.all().map {
            $0.toDTO()
        }

        struct ConfigsListResponse: Encodable {
            var title: String
            var configs: [ConfigurationDTO]
        }

        return try await req.view.render(
            "configs/list",
            ConfigsListResponse(
                title: "Configurations List",
                configs: configs
            ))
    }

    @Sendable
    func show(req: Request) async throws -> View {
        guard let config = try await Configuration.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        struct ConfigShowResponse: Encodable {
            var title: String
            var config: ConfigurationDTO
        }

        // TODO: ugly
        let rels = try await config.$flagRelations.get(on: req.db)
        for rel in rels {
            let _ = try await rel.$flag.get(on: req.db)
        }

        return try await req.view.render(
            "configs/show",
            ConfigShowResponse(
                title: "Configuration \"\(config.name)\"",
                config: config.toDTO()
            )
        )
    }

    @Sendable
    func apiList(req: Request) async throws -> [ConfigurationDTO] {
        return try await Configuration.query(on: req.db).with(\.$flagRelations) { $0.with(\.$flag) }
            .all().map {
                $0.toDTO()
            }
    }

    @Sendable
    func createForm(req: Request) async throws -> View {
        return try await req.view.render(
            "configs/form",
            ["title:": "Configuration Form"]
        )
    }

    @Sendable
    func updateForm(req: Request) async throws -> View {
        struct ConfigsUpdateFormData: Encodable {
            var title: String
            var config: ConfigurationDTO
        }

        guard let config = try await Configuration.find(req.parameters.get("id"), on: req.db)
        else {
            throw Abort(.notFound)
        }

        let rels = try await config.$flagRelations.get(on: req.db)
        for rel in rels {
            let _ = try await rel.$flag.get(on: req.db)
        }

        return try await req.view.render(
            "configs/form",
            ConfigsUpdateFormData(
                title: "Config Update Form",
                config: config.toDTO()
            )
        )
    }

    @Sendable
    func create(req: Request) async throws -> Response {
        let config = try req.content.decode(ConfigurationFormData.self).toModel()

        config.updatedAt = Date()

        try await config.save(on: req.db)
        return req.redirect(to: "/configs")
    }

    @Sendable
    func update(req: Request) async throws -> Response {
        guard let id = req.parameters.get("id", as: UUID.self) else {
            throw Abort(.badRequest)
        }
        let input = try req.content.decode(ConfigurationFormData.self)

        guard let config = try await Configuration.find(id, on: req.db)
        else {
            throw Abort(.badRequest)
        }

        config.updatedAt = Date()
        config.applicationContext = input.context
        config.name = input.name
        config.description = input.description
        config.bsmURL = input.bsmURL
        config.cmsURL = input.cmsURL
        config.dpURL = input.dpURL

        try await config.update(on: req.db)
        return req.redirect(to: "/configs/\(id)")
    }

    @Sendable
    func delete(req: Request) async throws -> Response {
        guard let config = try await Configuration.find(req.parameters.get("id"), on: req.db)
        else {
            throw Abort(.notFound)
        }

        try await config.delete(on: req.db)
        return req.redirect(to: "/configs")
    }
}
