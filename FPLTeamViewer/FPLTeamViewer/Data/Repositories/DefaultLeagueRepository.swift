import Foundation
import OSLog

struct DefaultLeagueRepository: LeagueRepository {
    private let apiClient: any FPLAPIClient
    private let cache: any SnapshotCache
    private let logger = Logger(subsystem: "com.seeclear.FPLTeamViewer", category: "Repository")

    init(
        apiClient: any FPLAPIClient,
        cache: any SnapshotCache
    ) {
        self.apiClient = apiClient
        self.cache = cache
    }

    func cachedSnapshot() async throws -> LeagueSnapshot? {
        try await cache.load()
    }

    func refresh() async throws -> LeagueSnapshot {
        let dto = try await apiClient.fetchBootstrap()
        try Task.checkCancellation()
        let snapshot = try LeagueMapper().map(dto)
        try Task.checkCancellation()

        do {
            try await cache.save(snapshot)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            logger.warning("Could not save team cache: \(error.localizedDescription)")
        }

        return snapshot
    }
}
