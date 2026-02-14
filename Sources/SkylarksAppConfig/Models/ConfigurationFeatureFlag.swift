import Fluent

import struct Foundation.UUID

final class ConfigurationFeatureFlag: Model, @unchecked Sendable {
    static let schema = "config+flag"

    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "config_id")
    var config: Configuration
    
    @Parent(key: "flag_id")
    var flag: FeatureFlag
    
    @Field(key: "enabled")
    var enabled: Bool
    
    init() {}
    
    init(id: UUID? = nil, config: Configuration, flag: FeatureFlag, enabled: Bool) throws {
        self.id = id
        self.enabled = enabled
        self.$config.id = try config.requireID()
        self.$config.id = try flag.requireID()
    }
}