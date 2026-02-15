import Fluent
import Vapor

struct FeatureFlagController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let flags = routes.grouped("flags")
        
        flags.get(use: self.index)
        
        let api = routes.grouped("api")

        api.get("flags", use: self.apiList)
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
}