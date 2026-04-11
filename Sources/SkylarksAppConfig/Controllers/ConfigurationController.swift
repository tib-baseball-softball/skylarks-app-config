import Fluent
import Vapor

/// A controller that manages configuration related routes and logic.
///
/// `ConfigurationController` handles both web views and API endpoints for creating,
/// viewing, updating, and deleting application configurations.
struct ConfigurationController: RouteCollection {
    /// Registers the routes for configuration management to the provided `RoutesBuilder`.
    ///
    /// - Parameter routes: The `RoutesBuilder` to register routes with.
    /// - Throws: An error if route registration fails.
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
        let v1 = api.grouped("v1")

        v1.get("configs", use: self.apiList)
    }

    /// Renders a web view listing all configurations.
    ///
    /// - Parameter req: The incoming `Request`.
    /// - Returns: A `View` rendering the "configs/list" template.
    /// - Throws: An error if database access or view rendering fails.
    @Sendable
    func index(req: Request) async throws -> View {
        let configs = try await Configuration.query(on: req.db).with(\.$flagRelations) {
            $0.with(\.$flag)
        }.all().map {
            $0.toDTO()
        }

        /// A response object for rendering the configurations list.
        struct ConfigsListResponse: Encodable {
            /// The title of the page.
            var title: String
            /// The list of configuration DTOs.
            var configs: [ConfigurationDTO]
        }

        return try await req.view.render(
            "configs/list",
            ConfigsListResponse(
                title: "Configurations List",
                configs: configs
            ))
    }

    /// Renders a web view showing details for a specific configuration.
    ///
    /// - Parameter req: The incoming `Request` with an "id" parameter.
    /// - Returns: A `View` rendering the "configs/show" template.
    /// - Throws: A `.notFound` error if the configuration doesn't exist.
    @Sendable
    func show(req: Request) async throws -> View {
        guard let config = try await Configuration.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }

        /// A response object for rendering the configuration detail view.
        struct ConfigShowResponse: Encodable {
            /// The title of the page.
            var title: String
            /// The configuration DTO.
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

    /// Provides an API list of all configurations with their associated feature flags.
    ///
    /// Can be filtered by application context via GET parameter.
    ///
    /// - Parameter req: The incoming `Request`.
    /// - Returns: An array of `ConfigurationDTO` objects.
    /// - Throws: An error if database access fails.
    @Sendable
    func apiList(req: Request) async throws -> [ConfigurationDTO] {
        let query = Configuration.query(on: req.db).with(\.$flagRelations) { $0.with(\.$flag) }
        
        var context: ApplicationContext?
        
        do {
            context = try req.query.get(ApplicationContext.self, at: ["context"])
        } catch {
            context = nil
        }
        
        if let ctx = context {
            query.filter(\.$applicationContext == ctx)
        }

        return try await query.all().map { $0.toDTO() }
    }

    /// Renders the form for creating a new configuration.
    ///
    /// - Parameter req: The incoming `Request`.
    /// - Returns: A `View` rendering the "configs/form" template.
    /// - Throws: An error if view rendering fails.
    @Sendable
    func createForm(req: Request) async throws -> View {
        return try await req.view.render(
            "configs/form",
            ["title:": "Configuration Form"]
        )
    }

    /// Renders the form for updating an existing configuration.
    ///
    /// - Parameter req: The incoming `Request` with an "id" parameter.
    /// - Returns: A `View` rendering the "configs/form" template with existing data.
    /// - Throws: A `.notFound` error if the configuration doesn't exist.
    @Sendable
    func updateForm(req: Request) async throws -> View {
        /// A response object for rendering the configuration update form.
        struct ConfigsUpdateFormData: Encodable {
            /// The title of the page.
            var title: String
            /// The existing configuration data.
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

    /// Creates a new configuration and redirects to the listing page.
    ///
    /// - Parameter req: The incoming `Request` containing form data.
    /// - Returns: A `Response` redirecting to "/configs".
    /// - Throws: An error if the data is invalid or database save fails.
    @Sendable
    func create(req: Request) async throws -> Response {
        let config = try req.content.decode(ConfigurationFormData.self).toModel()

        config.updatedAt = Date()

        try await config.save(on: req.db)
        return req.redirect(to: "/configs")
    }

    /// Updates an existing configuration and redirects to its detail view.
    ///
    /// - Parameter req: The incoming `Request` with an "id" parameter and form data.
    /// - Returns: A `Response` redirecting to the updated configuration's show page.
    /// - Throws: A `.badRequest` error if the ID is missing or configuration not found.
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

    /// Deletes a configuration by its ID and redirects to the listing page.
    ///
    /// - Parameter req: The incoming `Request` containing the ID as a parameter.
    /// - Returns: A `Response` redirecting to "/configs".
    /// - Throws: A `.notFound` error if the configuration doesn't exist.
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
