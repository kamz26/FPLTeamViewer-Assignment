import UIKit

@MainActor
final class SquadViewController: UIViewController, UITableViewDelegate, UISearchResultsUpdating {
    private let viewModel: SquadViewModel
    private var playersByID: [Player.ID: Player] = [:]

    private lazy var tableView = DiffableTableView<Position, Player.ID>(style: .insetGrouped) { [weak self] tableView, indexPath, id in
        let cell = tableView.dequeueReusableCell(withIdentifier: "Player", for: indexPath)
        guard let player = self?.playersByID[id] else { return cell }
        var content = cell.defaultContentConfiguration()
        content.text = player.displayName
        content.secondaryText = "\(player.position.shortTitle) · £\(player.price.formatted(.number.precision(.fractionLength(1))))m · \(player.totalPoints) pts"
        cell.contentConfiguration = content
        return cell
    }

    init(viewModel: SquadViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("Use init(viewModel:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.team.name
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Player")
        tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "Section")
        tableView.delegate = self
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        viewModel.onChange = { [weak self] in self?.render() }
        render()
    }

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.query = searchController.searchBar.text ?? ""
    }

    private func render() {
        switch viewModel.state {
        case let .content(sections):
            playersByID = Dictionary(uniqueKeysWithValues: sections.flatMap(\.players).map { ($0.id, $0) })
            tableView.backgroundView = nil
            tableView.apply(sections.map { ($0.position, $0.players.map(\.id)) })
        case .empty:
            playersByID = [:]
            let label = UILabel()
            label.text = "No players found"
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            tableView.backgroundView = label
            tableView.apply([])
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let position = self.tableView.section(at: section) else { return nil }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "Section")
        var content = header?.defaultContentConfiguration()
        content?.text = position.title
        header?.contentConfiguration = content
        return header
    }
}
