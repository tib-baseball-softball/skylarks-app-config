import Fluent
import Vapor

struct ConfigurationDTO: Content {
    var id: UUID?
    var updatedAt: Date
    var name: String
    var applicationContext: ApplicationContext
    var description: String?
    var apiURLS: APIUrls
    var flagRelations: [FlagWithStatusDTO]?

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
            model.flagRelations = flags.map { 
                let rel = $0.toModel()
                rel.config = model
                
                return rel
            }
        }

        return model
    }

    struct APIUrls: Content {
        var bsmURL: String
        var cmsURL: String
        var dpURL: String
    }
}

struct FlagWithStatusDTO: Content {
    var flag: FeatureFlagDTO
    var enabled: Bool

    func toModel() -> ConfigurationFeatureFlag {
        let model = ConfigurationFeatureFlag()
        model.flag = self.flag.toModel()
        model.enabled = self.enabled
        return model
    }
}
