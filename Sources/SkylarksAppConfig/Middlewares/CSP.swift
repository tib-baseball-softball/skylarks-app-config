import Vapor

/// Middleware that adds our restrictive Content-Security-Policy header to responses.
/// Only requests to internal resources and CDN for CSS are allowed.
struct CSPMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response
    {
        let response = try await next.respond(to: request)
        response.headers.add(
            name: "Content-Security-Policy",
            value:
                "default-src 'self'; form-action 'self'; style-src-elem 'self' https://*.jsdelivr.net"
        )
        return response
    }
}
