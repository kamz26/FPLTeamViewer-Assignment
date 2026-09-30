import UIKit

@MainActor
final class AppRouter {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func showSquad(for team: Team, players: [Player]) {
        let viewModel = SquadViewModel(team: team, players: players)
        navigationController?.pushViewController(SquadViewController(viewModel: viewModel), animated: true)
    }
}
