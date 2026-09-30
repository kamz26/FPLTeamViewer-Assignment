import Foundation
import OSLog

protocol SnapshotCache: Sendable {
    func load() async throws -> LeagueSnapshot?
    func save(_ snapshot: LeagueSnapshot) async throws
}

actor FileSnapshotCache: SnapshotCache {
    private let fileURL: URL
    private let logger = Logger(subsystem: "com.seeclear.FPLTeamViewer", category: "Cache")

    init(
        fileManager: FileManager = .default,
        directory: URL? = nil,
        filename: String = "fpl-league-snapshot.json"
    ) {
        let baseDirectory = directory ?? fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!
        fileURL = baseDirectory.appendingPathComponent(filename)
    }

    func load() throws -> LeagueSnapshot? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }

        let data = try Data(contentsOf: fileURL)
        do {
            return try JSONDecoder().decode(LeagueSnapshot.self, from: data)
        } catch {
            logger.warning("Ignoring unreadable team cache: \(error.localizedDescription)")
            return nil
        }
    }

    func save(_ snapshot: LeagueSnapshot) throws {
        let data = try JSONEncoder().encode(snapshot)
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try data.write(to: fileURL, options: .atomic)
    }
}
