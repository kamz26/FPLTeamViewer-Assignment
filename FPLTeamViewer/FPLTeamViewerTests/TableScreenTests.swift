import UIKit
import XCTest
@testable import FPLTeamViewer

@MainActor
final class TableScreenTests: XCTestCase {
    func testTeamSnapshotRendersCellsAndSelectionShowsSquad() async throws {
        let repository = RepositoryStub(cached: nil, behavior: .succeed(Fixtures.snapshot))
        let viewModel = TeamsViewModel(repository: repository)
        await viewModel.load()

        let navigation = UINavigationController()
        let router = AppRouter(navigationController: navigation)
        let teams = TeamsViewController(viewModel: viewModel, router: router)
        navigation.viewControllers = [teams]
        teams.loadViewIfNeeded()

        let table = try XCTUnwrap(teams.view.subviews.compactMap { $0 as? UITableView }.first)
        XCTAssertEqual(table.numberOfRows(inSection: 0), 2)
        let firstRow = IndexPath(row: 0, section: 0)
        let cell = try XCTUnwrap(table.dataSource?.tableView(table, cellForRowAt: firstRow))
        XCTAssertEqual((cell.contentConfiguration as? UIListContentConfiguration)?.text, "Alpha FC")

        table.delegate?.tableView?(table, didSelectRowAt: firstRow)
        let squad = try XCTUnwrap(navigation.topViewController as? SquadViewController)
        squad.loadViewIfNeeded()
        let squadTable = try XCTUnwrap(squad.view.subviews.compactMap { $0 as? UITableView }.first)
        XCTAssertEqual(squadTable.numberOfSections, 4)
        XCTAssertEqual((0..<4).reduce(0) { $0 + squadTable.numberOfRows(inSection: $1) }, 5)
    }
}
