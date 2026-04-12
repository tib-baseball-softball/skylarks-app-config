import Vapor

/// In-memory user provided by basic auth.
struct User: Authenticatable {
    var name: String
}