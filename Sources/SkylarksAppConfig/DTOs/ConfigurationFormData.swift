import Fluent
import Vapor

/// A data transfer object representing the configuration data typically submitted via a form.
///
/// `ConfigurationFormData` simplified DTO for creating or updating a `Configuration` model.
struct ConfigurationFormData: Content {
    /// The unique identifier for the configuration (optional for new ones).
    var id: UUID?
    /// The name of the configuration.
    var name: String
    /// The application context this configuration applies to.
    var context: ApplicationContext
    /// An optional description of the configuration.
    var description: String?
    /// The URL for the BSM service.
    var bsmURL: String
    /// The URL for the CMS service.
    var cmsURL: String
    /// The URL for the DP service.
    var dpURL: String

    /// Converts the form data into its corresponding `Configuration` database model.
    ///
    /// - Returns: A `Configuration` model initialized with this form data.
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
