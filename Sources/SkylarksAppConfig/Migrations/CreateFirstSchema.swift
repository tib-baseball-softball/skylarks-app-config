import Fluent

struct CreateFirstSchema: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let contextEnumType = try await database.enum("application_context")
            .case("production")
            .case("staging")
            .create()

        try await database.schema("configurations")
            .id()
            .unique(on: "name")
            .field("name", .string, .required)
            .field("updated_at", .datetime, .required)
            .field("description", .string)
            .field("context", contextEnumType, .required)
            .field("bsm_url", .string, .required)
            .field("cms_url", .string, .required)
            .field("dp_url", .string, .required)
            .create()

        try await database.schema("feature_flags")
            .id()
            .unique(on: "key")
            .field("key", .string, .required)
            .field("description", .string)
            .create()

        try await database.schema("config+flag")
            .id()
            .unique(on: "config_id", "flag_id")
            .field("config_id", .uuid, .required, .references("configurations", "id"))
            .field("flag_id", .uuid, .required, .references("feature_flags", "id"))
            .field("enabled", .bool, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        // throw DB away
    }
}
