import Fluent
import Vapor

struct FeatureFlagUsagePayload: Content {
    let configID: UUID
    let flagID: UUID
    let enabled: Bool
}
