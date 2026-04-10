import Fluent

import struct Foundation.UUID

/// A model representing a feature flag in the Skylarks application.
///
/// `FeatureFlag` defines a toggleable feature that can be enabled or disabled
/// across different configurations.
final class FeatureFlag: Model, @unchecked Sendable {
    /// The unique schema name used by Fluent for the `feature_flags` table.
    static let schema = "feature_flags"

    /// The unique identifier for the feature flag.
    @ID(key: .id)
    var id: UUID?

    /// The unique key used to identify the feature flag in the application code.
    @Field(key: "key")
    var key: String

    /// An optional description of the feature flag's purpose.
    @OptionalField(key: "description")
    var description: String?

    /// The configurations associated with this feature flag through a many-to-many relationship.
    @Siblings(through: ConfigurationFeatureFlag.self, from: \.$flag, to: \.$config)
    var configs: [Configuration]

    /// Initializes a new empty `FeatureFlag` instance.
    init() {}

    /// Initializes a new `FeatureFlag` with the specified properties.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the feature flag.
    ///   - key: The unique key for the feature flag.
    ///   - description: An optional description.
    init(id: UUID? = nil, key: String, description: String?) {
        self.id = id
        self.key = key
        self.description = description
    }

    /// Converts the `FeatureFlag` model into a data transfer object (DTO).
    ///
    /// - Returns: A `FeatureFlagDTO` representing the current feature flag state.
    func toDTO() -> FeatureFlagDTO {
        .init(id: self.id, key: self.key, description: self.description)
    }
}
