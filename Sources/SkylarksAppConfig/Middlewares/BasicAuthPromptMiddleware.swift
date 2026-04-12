import Vapor

/// Middleware that adds the `www-authenticate` header to all responses to unauthorized requests, prompting the browser
/// to ask for basic auth credentials.
/// 
/// Vapor's `guardMiddleware()` only sets the response code.
struct BasicAuthPromptMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response
    {
        let response = try await next.respond(to: request)

        if response.status == .unauthorized {
            response.headers.replaceOrAdd(
                name: "www-authenticate",
                value: "Basic"
            )
        }
        return response
    }
}
