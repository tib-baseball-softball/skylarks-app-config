import Fluent
import Vapor

/// A data transfer object representing a feature flag's basic information.
///
/// `FeatureFlagDTO` is used for sending and receiving feature flag data over the network.
struct FeatureFlagDTO: Content {
    /// The unique identifier for the feature flag.
    var id: UUID?
    /// The unique key identifying the feature flag.
    var key: String
    /// An optional description of the feature flag.
    var description: String?

    /// Converts the DTO into its corresponding `FeatureFlag` database model.
    ///
    /// - Returns: A `FeatureFlag` model initialized with this DTO's data.
    func toModel() -> FeatureFlag {
        let model = FeatureFlag()

        model.id = self.id
        model.key = self.key
        model.description = self.description
        return model
    }
}
