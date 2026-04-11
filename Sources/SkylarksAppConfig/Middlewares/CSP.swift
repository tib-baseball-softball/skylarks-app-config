import Vapor

/// Middleware that adds a restrictive Content-Security-Policy (CSP) header to responses.
///
/// This middleware ensures that only requests to internal resources and approved CDNs
/// (like jsdelivr.net for CSS) are allowed, enhancing the application's security.
struct CSPMiddleware: AsyncMiddleware {
    /// Responds to an incoming request by adding a CSP header to the response.
    ///
    /// - Parameters:
    ///   - request: The incoming `Request`.
    ///   - next: The next `AsyncResponder` in the chain.
    /// - Returns: The `Response` with the CSP header added.
    /// - Throws: An error if the next responder fails.
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response
    {
        let response = try await next.respond(to: request)

        if request.url.path != "/static/api-docs.html" {
            response.headers.add(
                name: "Content-Security-Policy",
                value:
                    "default-src 'self'; form-action 'self'; style-src-elem 'self' https://*.jsdelivr.net"
            )
        }
        return response
    }
}
