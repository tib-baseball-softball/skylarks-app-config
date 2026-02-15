import Fluent
import Vapor

struct FeatureFlagDTO: Content {
    var id: UUID?
    var key: String
    var description: String?

    func toModel() -> FeatureFlag {
        let model = FeatureFlag()

        model.id = self.id
        model.key = self.key
        model.description = self.description
        return model
    }
}
