import Fluent

struct CreateConfiguration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("configurations")
            .id()
            .field("description", .string, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("configurations").delete()
    }
}
