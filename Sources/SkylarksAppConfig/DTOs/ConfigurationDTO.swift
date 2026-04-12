import Fluent
import Vapor

/// A data transfer object representing a complete system configuration.
///
/// `ConfigurationDTO` is used for sending and receiving detailed configuration data in internal leaf routes.
struct ConfigurationDTO: Content {
    /// The unique identifier for the configuration.
    var id: UUID?
    /// The last update timestamp for the configuration.
    var updatedAt: Date
    /// The name of the configuration.
    var name: String
    /// The application context this configuration applies to.
    var applicationContext: ApplicationContext
    /// An optional description of the configuration.
    var description: String?
    /// The set of service URLs for this configuration.
    var apiURLS: APIUrls
    /// An optional list of feature flags and their enabled status for this configuration.
    var flagRelations: [FlagWithStatusDTO]?

    /// Converts the DTO into its corresponding `Configuration` database model.
    ///
    /// - Returns: A `Configuration` model initialized with this DTO's data.
    func toModel() -> Configuration {
        let model = Configuration()

        model.id = self.id
        model.name = self.name
        model.applicationContext = self.applicationContext
        model.updatedAt = self.updatedAt
        model.description = self.description
        model.bsmURL = self.apiURLS.bsmURL
        model.cmsURL = self.apiURLS.cmsURL
        model.dpURL = self.apiURLS.dpURL
        if let flags = self.flagRelations {
            model.flagRelations = flags.lazy.map {
                let rel = $0.toModel()
                rel.config = model

                return rel
            }
        }

        return model
    }
}

/// A data transfer object representing a complete system configuration.
///
/// `ConfigurationAPIDTO` is used for API responses, providing feature flags as a map.
/// NB: There is no `toModel()` method as receiving data this way is not planned.
struct ConfigurationAPIDTO: Content {
    /// The unique identifier for the configuration.
    var id: UUID?
    /// The last update timestamp for the configuration.
    var updatedAt: Date
    /// The name of the configuration.
    var name: String
    /// The application context this configuration applies to.
    var applicationContext: ApplicationContext
    /// An optional description of the configuration.
    var description: String?
    /// The set of service URLs for this configuration.
    var apiURLS: APIUrls
    /// An optional hashmap of feature flags and their enabled status for this configuration.
    var flagRelations: [String: FlagWithStatusDTO]?
}

/// A nested DTO containing various service URLs.
struct APIUrls: Content {
    /// The URL for the BSM service.
    var bsmURL: String
    /// The URL for the CMS service.
    var cmsURL: String
    /// The URL for the DP service.
    var dpURL: String
}

/// A data transfer object representing a feature flag along with its status for a single configuration.
struct FlagWithStatusDTO: Content {
    /// The feature flag's information.
    var flag: FeatureFlagDTO
    /// Whether the flag is enabled.
    var enabled: Bool

    /// Converts the DTO into its corresponding `ConfigurationFeatureFlag` pivot model.
    ///
    /// - Returns: A `ConfigurationFeatureFlag` model initialized with this DTO's data.
    func toModel() -> ConfigurationFeatureFlag {
        let model = ConfigurationFeatureFlag()
        model.flag = self.flag.toModel()
        model.enabled = self.enabled
        return model
    }
}
