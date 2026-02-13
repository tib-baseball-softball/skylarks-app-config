import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Configuration: Model, @unchecked Sendable {
    static let schema = "configurations"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "description")
    var description: String

    init() { }

    init(id: UUID? = nil, description: String) {
        self.id = id
        self.description = description
    }
    
    func toDTO() -> ConfigurationDTO {
        .init(
            id: self.id,
            description: self.$description.value
        )
    }
}
