import XCTest
@testable import FPLTeamViewer

final class FileSnapshotCacheTests: XCTestCase {
    func testRoundTripsSnapshot() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let cache = FileSnapshotCache(directory: directory)

        try await cache.save(Fixtures.snapshot)
        let loaded = try await cache.load()

        XCTAssertEqual(loaded, Fixtures.snapshot)
    }

    func testCorruptCacheIsIgnoredAndCanBeReplaced() async throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("{".utf8).write(to: directory.appendingPathComponent("fpl-league-snapshot.json"))
        let cache = FileSnapshotCache(directory: directory)

        let corruptResult = try await cache.load()
        XCTAssertNil(corruptResult)

        try await cache.save(Fixtures.snapshot)
        let recoveredResult = try await cache.load()
        XCTAssertEqual(recoveredResult, Fixtures.snapshot)
    }
}
