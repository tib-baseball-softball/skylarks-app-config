import Vapor

/// Checks basic auth values from the environment.
struct UserAuthenticator: AsyncBasicAuthenticator {
    /// Performs the actual authentication.
    func authenticate(
        basic: BasicAuthorization,
        for request: Request
    ) async throws {
        guard let basicUserName = Environment.get("BASIC_AUTH_USERNAME") else {
            throw EnvironmentNotSetError.userNotSet
        }
        guard let basicUserPass = Environment.get("BASIC_AUTH_PASSWORD") else {
            throw EnvironmentNotSetError.passwordNotSet
        }

        if basic.username == basicUserName && basic.password == basicUserPass {
            request.auth.login(User(name: "Admin"))
        }
    }
}
