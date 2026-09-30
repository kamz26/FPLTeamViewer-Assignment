import XCTest
@testable import FPLTeamViewer

@MainActor
final class TeamsViewModelTests: XCTestCase {
    func testInitialFailureShowsRetryableFailure() async {
        let repository = RepositoryStub(cached: nil, behavior: .fail(.offline))
        let viewModel = TeamsViewModel(repository: repository)

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .failed("No internet connection."))
    }

    func testRefreshFailureKeepsCachedContentVisible() async {
        let repository = RepositoryStub(cached: Fixtures.snapshot, behavior: .fail(.offline))
        let viewModel = TeamsViewModel(repository: repository)
        var refreshErrors: [String] = []
        viewModel.onRefreshError = { refreshErrors.append($0) }

        await viewModel.load()

        guard case let .content(rows) = viewModel.state else {
            return XCTFail("Expected cached content to remain visible")
        }
        XCTAssertEqual(rows.count, Fixtures.snapshot.teams.count)
        XCTAssertEqual(refreshErrors, ["No internet connection."])
    }

    func testFailureWithEmptyCacheShowsRetryInsteadOfStaleDataAlert() async {
        let empty = LeagueSnapshot(teams: [], players: [])
        let repository = RepositoryStub(cached: empty, behavior: .fail(.offline))
        let viewModel = TeamsViewModel(repository: repository)
        var refreshErrors: [String] = []
        viewModel.onRefreshError = { refreshErrors.append($0) }

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .failed("No internet connection."))
        XCTAssertTrue(refreshErrors.isEmpty)
    }

    func testPullToRefreshDoesNotRaceInitialLoad() async {
        let repository = PausedRepository()
        let viewModel = TeamsViewModel(repository: repository)
        let load = Task { await viewModel.load() }

        await repository.waitUntilRefreshStarts()
        let duplicateStarted = expectation(description: "Duplicate refresh started")
        var duplicateFinished = false
        let duplicate = Task {
            duplicateStarted.fulfill()
            await viewModel.refresh()
            duplicateFinished = true
        }
        await fulfillment(of: [duplicateStarted], timeout: 1)
        XCTAssertFalse(duplicateFinished)
        let callsWhileLoading = await repository.refreshCount
        XCTAssertEqual(callsWhileLoading, 1)

        await repository.completeRefresh()
        await duplicate.value
        await load.value
        XCTAssertTrue(duplicateFinished)
        let totalCalls = await repository.refreshCount
        XCTAssertEqual(totalCalls, 1)
        guard case .content = viewModel.state else {
            return XCTFail("Expected the first refresh to populate teams")
        }
    }
}

private actor PausedRepository: LeagueRepository {
    private(set) var refreshCount = 0
    private var startWaiter: CheckedContinuation<Void, Never>?
    private var pendingRefresh: CheckedContinuation<LeagueSnapshot, Error>?

    func cachedSnapshot() -> LeagueSnapshot? { nil }

    func refresh() async throws -> LeagueSnapshot {
        refreshCount += 1
        if refreshCount > 1 { return Fixtures.snapshot }
        startWaiter?.resume()
        startWaiter = nil
        return try await withCheckedThrowingContinuation { pendingRefresh = $0 }
    }

    func waitUntilRefreshStarts() async {
        guard refreshCount == 0 else { return }
        await withCheckedContinuation { startWaiter = $0 }
    }

    func completeRefresh() {
        pendingRefresh?.resume(returning: Fixtures.snapshot)
        pendingRefresh = nil
    }
}
