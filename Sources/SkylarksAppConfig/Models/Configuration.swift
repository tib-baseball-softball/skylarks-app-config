import Fluent

import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Configuration: Model, @unchecked Sendable {
    static let schema = "configurations"

    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "updated_at")
    var updatedAt: Date
    
    @Field(key: "name")
    var name: String
    
    @Enum(key: "context")
    var applicationContext: ApplicationContext

    @OptionalField(key: "description")
    var description: String?

    @Field(key: "bsm_url")
    var bsmURL: String

    @Field(key: "cms_url")
    var cmsURL: String

    @Field(key: "dp_url")
    var dpURL: String
    
    @Siblings(through: ConfigurationFeatureFlag.self, from: \.$config, to: \.$flag)
    var featureFlags: [FeatureFlag]

    init() {}

    init(id: UUID? = nil, updatedAt: Date, description: String, bsmURL: String, cmsURL: String, dpURL: String, featureFlags: [FeatureFlag]) {
        self.id = id
        self.updatedAt = updatedAt
        self.description = description
        self.cmsURL = cmsURL
        self.bsmURL = bsmURL
        self.dpURL = dpURL
        self.featureFlags = featureFlags
    }

    func toDTO() -> ConfigurationDTO {
        .init(
            id: self.id,
            description: self.$description.wrappedValue,
            apiURLS: ConfigurationDTO.APIUrls(
                bsmURL: self.bsmURL, cmsURL: self.cmsURL, dpURL: self.dpURL)
        )
    }
}
