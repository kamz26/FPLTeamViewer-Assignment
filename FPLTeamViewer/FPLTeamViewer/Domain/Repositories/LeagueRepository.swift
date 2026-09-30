protocol LeagueRepository: Sendable {
    func cachedSnapshot() async throws -> LeagueSnapshot?
    func refresh() async throws -> LeagueSnapshot
}
