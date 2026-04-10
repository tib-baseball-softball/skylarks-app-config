/// The environment or context in which the application is running.
///
/// `ApplicationContext` is used to determine which configuration settings
/// and feature flags should be applied.
enum ApplicationContext: String, Codable {
    /// The production environment.
    case production
    /// The staging environment, used for pre-release testing.
    case staging
    /// Local development environment.
    case development
}
