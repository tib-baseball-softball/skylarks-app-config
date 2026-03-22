import Fluent
import Vapor

struct FeatureFlagController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let flags = routes.grouped("flags")

        flags.get(use: self.index)
        flags.post("create", use: self.create)

        let api = routes.grouped("api")

        api.group("flags") { flags in
            flags.get(use: self.apiList)
        }
        
        let flagRels = routes.grouped("flag-relations")
        flagRels.post("upsert", use: self.upsertFlagRelation)

    }

    @Sendable
    func index(req: Request) async throws -> View {
        let flags = try await FeatureFlag.query(on: req.db).all().map { $0.toDTO() }

        struct ConfigsResponse: Encodable {
            var title: String
            var flags: [FeatureFlagDTO]
        }

        return try await req.view.render(
            "flags/list",
            ConfigsResponse(
                title: "Feature Flags List",
                flags: flags
            ))
    }

    @Sendable
    func apiList(req: Request) async throws -> [FeatureFlagDTO] {
        return try await FeatureFlag.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> Response {
        let config = try req.content.decode(FeatureFlagDTO.self).toModel()

        try await config.save(on: req.db)
        return req.redirect(to: "/flags")
    }

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
}
