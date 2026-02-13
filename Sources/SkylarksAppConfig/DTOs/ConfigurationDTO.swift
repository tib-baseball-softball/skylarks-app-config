import Fluent
import Vapor

struct ConfigurationDTO: Content {
    var id: UUID?
    var description: String?

    func toModel() -> Configuration {
        let model = Configuration()

        model.id = self.id
        if let description = self.description {
            model.description = description
        }
        return model
    }
}
