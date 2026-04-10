import Fluent

import struct Foundation.UUID

/// A pivot model representing the many-to-many relationship between `Configuration` and `FeatureFlag`.
///
/// This model stores whether a specific feature flag is enabled for a given configuration.
final class ConfigurationFeatureFlag: Model, @unchecked Sendable {
    /// The unique schema name used by Fluent for the pivot table.
    static let schema = "config+flag"

    /// The unique identifier for the relationship record.
    @ID(key: .id)
    var id: UUID?

    /// The configuration associated with this relationship.
    @Parent(key: "config_id")
    var config: Configuration

    /// The feature flag associated with this relationship.
    @Parent(key: "flag_id")
    var flag: FeatureFlag

    /// A boolean indicating whether the feature flag is enabled for the associated configuration.
    @Field(key: "enabled")
    var enabled: Bool

    /// Initializes a new empty `ConfigurationFeatureFlag` instance.
    init() {}

    /// Initializes a new `ConfigurationFeatureFlag` relationship with the specified properties.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the relationship record.
    ///   - config: The configuration to associate.
    ///   - flag: The feature flag to associate.
    ///   - enabled: Whether the flag is enabled for this configuration.
    /// - Throws: An error if the IDs for the configuration or flag cannot be retrieved.
    init(id: UUID? = nil, config: Configuration, flag: FeatureFlag, enabled: Bool) throws {
        self.id = id
        self.enabled = enabled
        self.$config.id = try config.requireID()
        self.$config.id = try flag.requireID()
    }
}
