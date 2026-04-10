import Fluent
import Vapor

/// A data transfer object representing the status of a feature flag for a specific configuration.
///
/// `FeatureFlagUsagePayload` is used when updating whether a flag is enabled or disabled.
struct FeatureFlagUsagePayload: Content {
    /// The unique identifier of the configuration to associate the flag with.
    let configID: UUID
    /// The unique identifier of the feature flag.
    let flagID: UUID
    /// A boolean indicating whether the flag should be enabled for this configuration.
    let enabled: Bool
}
