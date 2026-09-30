import XCTest
@testable import FPLTeamViewer

@MainActor
final class SquadViewModelTests: XCTestCase {
    func testGroupsPlayersInPositionOrderAndSortsByPoints() {
        let team = Fixtures.snapshot.teams.first { $0.id == 1 }!
        let players = Fixtures.snapshot.players.filter { $0.teamID == team.id }
        let viewModel = SquadViewModel(team: team, players: players)

        guard case let .content(sections) = viewModel.state else {
            return XCTFail("Expected content state")
        }
        XCTAssertEqual(sections.map(\.position), Position.allCases)
        XCTAssertEqual(sections.first { $0.position == .forward }?.players.map(\.displayName), ["Finisher", "Forward"])
    }

    func testSearchCanProduceEmptyState() {
        let team = Fixtures.snapshot.teams.first { $0.id == 1 }!
        let players = Fixtures.snapshot.players.filter { $0.teamID == team.id }
        let viewModel = SquadViewModel(team: team, players: players)

        viewModel.query = "FIN"
        guard case let .content(sections) = viewModel.state else {
            return XCTFail("Expected matching players")
        }
        XCTAssertEqual(sections.flatMap(\.players).map(\.displayName), ["Finisher"])

        viewModel.query = "not a player"

        XCTAssertEqual(viewModel.state, .empty(searchText: "not a player"))
    }

}
