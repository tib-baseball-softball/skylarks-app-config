import Fluent

import struct Foundation.UUID

final class FeatureFlag: Model, @unchecked Sendable {
    static let schema = "feature_flags"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "key")
    var key: String

    @OptionalField(key: "description")
    var description: String?

    @Siblings(through: ConfigurationFeatureFlag.self, from: \.$flag, to: \.$config)
    var configs: [Configuration]

    init() {}

    init(id: UUID? = nil, key: String, description: String?) {
        self.id = id
        self.key = key
        self.description = description
    }

    func toDTO() -> FeatureFlagDTO {
        .init(key: self.key, description: self.description)
    }
}
