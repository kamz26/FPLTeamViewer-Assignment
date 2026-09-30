import XCTest
@testable import FPLTeamViewer

final class DefaultLeagueRepositoryTests: XCTestCase {
    func testCacheWriteFailureDoesNotDiscardFreshData() async throws {
        let repository = DefaultLeagueRepository(apiClient: FixtureAPIClient(), cache: FailingCache())

        let snapshot = try await repository.refresh()

        XCTAssertEqual(snapshot, Fixtures.snapshot)
    }
}

private struct FixtureAPIClient: FPLAPIClient {
    func fetchBootstrap() -> BootstrapDTO { Fixtures.dto }
}

private actor FailingCache: SnapshotCache {
    func load() -> LeagueSnapshot? { nil }
    func save(_ snapshot: LeagueSnapshot) throws { throw TestError.offline }
}
