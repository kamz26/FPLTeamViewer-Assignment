import Foundation
@testable import FPLTeamViewer

enum Fixtures {
    static let json = Data(
        """
        {
          "teams": [
            {"id": 2, "name": "Beta FC", "short_name": "BET", "strength": 3},
            {"id": 1, "name": "Alpha FC", "short_name": "ALP", "strength": 4}
          ],
          "elements": [
            {"id": 11, "team": 1, "first_name": "Alex", "second_name": "Keeper", "web_name": "Keeper", "element_type": 1, "now_cost": 45, "total_points": 10},
            {"id": 12, "team": 1, "first_name": "Dan", "second_name": "Back", "web_name": "D. Back", "element_type": 2, "now_cost": 50, "total_points": 40},
            {"id": 13, "team": 1, "first_name": "Mia", "second_name": "Field", "web_name": "Field", "element_type": 3, "now_cost": 75, "total_points": 80},
            {"id": 14, "team": 1, "first_name": "Fran", "second_name": "Forward", "web_name": "Forward", "element_type": 4, "now_cost": 90, "total_points": 70},
            {"id": 15, "team": 1, "first_name": "Finn", "second_name": "Finisher", "web_name": "Finisher", "element_type": 4, "now_cost": 85, "total_points": 90},
            {"id": 21, "team": 2, "first_name": "Other", "second_name": "Player", "web_name": "Other", "element_type": 2, "now_cost": 40, "total_points": 2}
          ]
        }
        """.utf8
    )

    static let dto = try! JSONDecoder().decode(BootstrapDTO.self, from: json)
    static let snapshot = try! LeagueMapper().map(dto)
}

actor RepositoryStub: LeagueRepository {
    enum RefreshBehavior: Sendable {
        case succeed(LeagueSnapshot)
        case fail(TestError)
    }

    private let cached: LeagueSnapshot?
    private let behavior: RefreshBehavior

    init(cached: LeagueSnapshot?, behavior: RefreshBehavior) {
        self.cached = cached
        self.behavior = behavior
    }

    func cachedSnapshot() -> LeagueSnapshot? { cached }

    func refresh() throws -> LeagueSnapshot {
        switch behavior {
        case let .succeed(snapshot): snapshot
        case let .fail(error): throw error
        }
    }
}

enum TestError: LocalizedError, Sendable {
    case offline

    var errorDescription: String? { "No internet connection." }
}
