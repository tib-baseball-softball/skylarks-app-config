import Fluent
import Vapor

struct ConfigurationDTO: Content {
    var id: UUID?
    var description: String?
    var apiURLS: APIUrls

    func toModel() -> Configuration {
        let model = Configuration()

        model.id = self.id
        model.description = self.description
        model.bsmURL = self.apiURLS.bsmURL
        model.cmsURL = self.apiURLS.cmsURL
        model.dpURL = self.apiURLS.dpURL
        return model
    }
    
    struct APIUrls: Codable {
        var bsmURL: String
        var cmsURL: String
        var dpURL: String
    }
}


