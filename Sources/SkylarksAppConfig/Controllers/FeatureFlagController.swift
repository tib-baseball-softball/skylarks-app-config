import Fluent
import FluentSQL
import Vapor

/// A controller that manages feature flag related routes and logic.
///
/// `FeatureFlagController` handles both web views and API endpoints for creating,
/// listing, and deleting feature flags, as well as managing their relationships with configurations.
struct FeatureFlagController: RouteCollection {
    /// Registers the routes for feature flag management to the provided `RoutesBuilder`.
    ///
    /// - Parameter routes: The `RoutesBuilder` to register routes with.
    /// - Throws: An error if route registration fails.
    func boot(routes: any RoutesBuilder) throws {
        let protected = routes.grouped(UserAuthenticator())
            .grouped(User.guardMiddleware())
        let flags = protected.grouped("flags")

        flags.get(use: self.index)
        flags.post("create", use: self.create)
        flags.group(":id") { flag in
            flag.post("delete", use: self.delete)
        }
        
        let flagRels = protected.grouped("flag-relations")
        flagRels.post("upsert", use: self.upsertFlagRelation)

        let api = routes.grouped("api")
        let v1 = api.grouped("v1")

        v1.group("flags") { flags in
            flags.get(use: self.apiList)
        }
    }

    /// Renders a web view listing all feature flags.
    ///
    /// - Parameter req: The incoming `Request`.
    /// - Returns: A `View` rendering the "flags/list" template.
    /// - Throws: An error if database access or view rendering fails.
    @Sendable
    func index(req: Request) async throws -> View {
        let flags = try await FeatureFlag.query(on: req.db).all().map { $0.toDTO() }

        /// A response object for rendering the feature flags list.
        struct ConfigsResponse: Encodable {
            /// The title of the page.
            var title: String
            /// The list of feature flag DTOs.
            var flags: [FeatureFlagDTO]
        }

        return try await req.view.render(
            "flags/list",
            ConfigsResponse(
                title: "Feature Flags List",
                flags: flags
            ))
    }

    /// Provides an API list of feature flags, optionally filtering out those already linked to a configuration.
    ///
    /// - Parameter req: The incoming `Request`, which may contain an `excludedConfigID` query parameter.
    /// - Returns: An array of `FeatureFlagDTO` objects.
    /// - Throws: An error if database access fails.
    @Sendable
    func apiList(req: Request) async throws -> [FeatureFlagDTO] {
        let excludedConfigID: UUID?

        do {
            excludedConfigID = try req.query.get(UUID.self, at: ["excludedConfigID"])
        } catch {
            excludedConfigID = nil
        }

        guard let sql = req.db as? any SQLDatabase else {
            throw Abort(.internalServerError, reason: "A server error occurred.")
        }

        // after several hours of trying to find the IS NULL syntax in the query builder equivalent I settled for the inflexible raw variant.
        if let exID = excludedConfigID {
            return try await sql.raw(
                """
                SELECT *
                FROM feature_flags AS flags
                LEFT JOIN 'config+flag' AS rel ON rel.flag_id = flags.id
                WHERE rel.config_id != \(bind: exID) OR rel.config_id IS NULL;
                """
            ).all(decodingFluent: FeatureFlag.self).map { $0.toDTO() }
        } else {
            return try await FeatureFlag.query(on: req.db).all().map { $0.toDTO() }
        }
    }

    /// Creates a new feature flag and redirects to the listing page.
    ///
    /// - Parameter req: The incoming `Request` containing the feature flag data in the body.
    /// - Returns: A `Response` redirecting to the "/flags" route.
    /// - Throws: An error if the data is invalid or database save fails.
    @Sendable
    func create(req: Request) async throws -> Response {
        let config = try req.content.decode(FeatureFlagDTO.self).toModel()

        try await config.save(on: req.db)
        return req.redirect(to: "/flags")
    }

    /// Updates or inserts a relationship between a configuration and a feature flag.
    ///
    /// - Parameter req: The incoming `Request` with a `FeatureFlagUsagePayload`.
    /// - Returns: A `Response` redirecting to the detailed view of the affected configuration.
    /// - Throws: An error if dependencies are not found or database operations fail.
    @Sendable
    func upsertFlagRelation(req: Request) async throws -> Response {
        let payload = try req.content.decode(FeatureFlagUsagePayload.self)

        let existingModel = try await ConfigurationFeatureFlag.query(on: req.db)
            .filter(\.$config.$id == payload.configID)
            .filter(\.$flag.$id == payload.flagID)
            .first()

        if let existingModel {
            existingModel.enabled = payload.enabled
            try await existingModel.save(on: req.db)

            return req.redirect(to: "/configs/\(payload.configID)")
        } else {
            guard (try await Configuration.find(payload.configID, on: req.db)) != nil else {
                throw Abort(.notFound, reason: "Configuration not found")
            }
            guard (try await FeatureFlag.find(payload.flagID, on: req.db)) != nil else {
                throw Abort(.notFound, reason: "Flag not found")
            }

            let newModel = ConfigurationFeatureFlag()
            newModel.$flag.id = payload.flagID
            newModel.$config.id = payload.configID
            newModel.enabled = payload.enabled

            try await newModel.save(on: req.db)

            return req.redirect(to: "/configs/\(payload.configID)")
        }
    }

    /// Deletes a feature flag by its ID and redirects to the listing page.
    ///
    /// - Parameter req: The incoming `Request` containing the ID as a parameter.
    /// - Returns: A `Response` redirecting to the "/flags" route.
    /// - Throws: A `.notFound` error if the flag doesn't exist, or database error.
    @Sendable
    func delete(req: Request) async throws -> Response {
        guard let config = try await FeatureFlag.find(req.parameters.get("id"), on: req.db)
        else {
            throw Abort(.notFound)
        }

        try await config.delete(on: req.db)
        return req.redirect(to: "/flags")
    }
}
