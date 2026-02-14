import Fluent
import Vapor

struct ConfigurationFormData: Content {
    var id: UUID?
    var name: String
    var context: ApplicationContext
    var description: String?
    var bsmURL: String
    var cmsURL: String
    var dpURL: String

    func toModel() -> Configuration {
        let model = Configuration()

        model.id = self.id
        model.name = self.name
        model.applicationContext = context
        model.description = self.description
        model.bsmURL = self.bsmURL
        model.cmsURL = self.cmsURL
        model.dpURL = self.dpURL
        return model
    }
}
