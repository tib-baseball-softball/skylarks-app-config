import Fluent
import Foundation

import struct Foundation.UUID

/// A model representing a system configuration.
///
/// `Configuration` stores the settings for different application contexts, including URLs for various
/// services and associations with feature flags.
final class Configuration: Model, @unchecked Sendable {
    /// The unique schema name used by Fluent for the `configurations` table.
    static let schema = "configurations"

    /// The unique identifier for the configuration.
    @ID(key: .id)
    var id: UUID?

    /// The date and time when the configuration was last updated.
    @Field(key: "updated_at")
    var updatedAt: Date

    /// The name of the configuration.
    @Field(key: "name")
    var name: String

    /// The application context this configuration applies to (e.g., development, production).
    @Enum(key: "context")
    var applicationContext: ApplicationContext

    /// An optional description of the configuration's purpose.
    @OptionalField(key: "description")
    var description: String?

    /// The URL for the BSM service.
    @Field(key: "bsm_url")
    var bsmURL: String

    /// The URL for the CMS service.
    @Field(key: "cms_url")
    var cmsURL: String

    /// The URL for the DP service.
    @Field(key: "dp_url")
    var dpURL: String

    /// The feature flags associated with this configuration through a many-to-many relationship.
    @Siblings(through: ConfigurationFeatureFlag.self, from: \.$config, to: \.$flag)
    var featureFlags: [FeatureFlag]

    /// The underlying pivot relationships between this configuration and its feature flags.
    @Children(for: \.$config)
    var flagRelations: [ConfigurationFeatureFlag]

    /// Initializes a new empty `Configuration` instance.
    init() {}

    /// Initializes a new `Configuration` with the specified properties.
    ///
    /// - Parameters:
    ///   - id: The unique identifier for the configuration.
    ///   - name: The name of the configuration.
    ///   - context: The application context.
    ///   - updatedAt: The last update timestamp.
    ///   - description: A description of the configuration.
    ///   - bsmURL: The BSM service URL.
    ///   - cmsURL: The CMS service URL.
    ///   - dpURL: The DP service URL.
    ///   - featureFlags: An array of associated feature flags.
    init(
        id: UUID? = nil, name: String, context: ApplicationContext, updatedAt: Date,
        description: String, bsmURL: String, cmsURL: String, dpURL: String,
        featureFlags: [FeatureFlag]
    ) {
        self.id = id
        self.name = name
        self.applicationContext = context
        self.updatedAt = updatedAt
        self.description = description
        self.cmsURL = cmsURL
        self.bsmURL = bsmURL
        self.dpURL = dpURL
        self.featureFlags = featureFlags
    }

    /// Converts the `Configuration` model into a data transfer object (DTO).
    ///
    /// - Returns: A `ConfigurationDTO` representing the current configuration state.
    func toDTO() -> ConfigurationDTO {
        .init(
            id: self.id,
            updatedAt: self.updatedAt,
            name: self.name,
            applicationContext: self.applicationContext,
            description: self.$description.wrappedValue,
            apiURLS: APIUrls(
                bsmURL: self.bsmURL, cmsURL: self.cmsURL, dpURL: self.dpURL),
            flagRelations: self.flagRelations.lazy.map({
                    FlagWithStatusDTO(flag: $0.flag.toDTO(), enabled: $0.enabled)
                })
        )
    }
    
    /// Converts the `Configuration` model into a data transfer object (DTO).
    ///
    /// - Returns: A `ConfigurationDTO` representing the current configuration state.
    func toAPIDTO() -> ConfigurationAPIDTO {
        .init(
            id: self.id,
            updatedAt: self.updatedAt,
            name: self.name,
            applicationContext: self.applicationContext,
            description: self.$description.wrappedValue,
            apiURLS: APIUrls(
                bsmURL: self.bsmURL, cmsURL: self.cmsURL, dpURL: self.dpURL),
            flagRelations: Dictionary(
                uniqueKeysWithValues: self.flagRelations.lazy.map({
                    ($0.flag.key, FlagWithStatusDTO(flag: $0.flag.toDTO(), enabled: $0.enabled))
                }))
        )
    }
}
