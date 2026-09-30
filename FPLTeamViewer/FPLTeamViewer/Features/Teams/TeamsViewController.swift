import UIKit

@MainActor
final class TeamsViewController: UIViewController, UITableViewDelegate {
    private let viewModel: TeamsViewModel
    private let router: AppRouter
    private var rowsByID: [Team.ID: TeamsViewModel.TeamRowModel] = [:]
    private var pendingRefreshError: String?

    private lazy var tableView = DiffableTableView<Int, Team.ID>(style: .insetGrouped) { [weak self] tableView, indexPath, id in
        let cell = tableView.dequeueReusableCell(withIdentifier: "Team", for: indexPath)
        guard let row = self?.rowsByID[id] else { return cell }
        var content = cell.defaultContentConfiguration()
        content.text = row.team.name
        content.secondaryText = "\(row.team.shortName) · \(row.players.count) players"
        content.image = UIImage(systemName: "shield.fill")
        content.imageProperties.tintColor = TeamColorPalette.resolve(shortName: row.team.shortName).background
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    init(viewModel: TeamsViewModel, router: AppRouter) {
        self.viewModel = viewModel
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("Use init(viewModel:router:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Premier League"
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Team")
        tableView.delegate = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        viewModel.onChange = { [weak self] in self?.render() }
        viewModel.onRefreshError = { [weak self] message in
            self?.pendingRefreshError = message
            self?.presentPendingRefreshError()
        }
        render()
        Task { await viewModel.load() }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentPendingRefreshError()
    }

    @objc private func refresh() {
        Task { await viewModel.refresh(); tableView.refreshControl?.endRefreshing() }
    }

    private func render() {
        switch viewModel.state {
        case .idle, .loading:
            rowsByID = [:]
            showStatus("Loading teams…")
        case .empty:
            rowsByID = [:]
            showStatus("No teams available")
        case let .failed(message):
            rowsByID = [:]
            showStatus(message, retry: true)
        case let .content(rows):
            let changedIDs = rows.compactMap { row -> Team.ID? in
                guard let old = rowsByID[row.id] else { return nil }
                return old.team != row.team || old.players.count != row.players.count ? row.id : nil
            }
            rowsByID = Dictionary(uniqueKeysWithValues: rows.map { ($0.id, $0) })
            tableView.backgroundView = nil
            tableView.apply([(0, rows.map(\.id))], reconfiguring: changedIDs)
        }
        if rowsByID.isEmpty { tableView.apply([]) }
    }

    private func presentPendingRefreshError() {
        guard let message = pendingRefreshError,
              viewIfLoaded?.window != nil,
              presentedViewController == nil else { return }
        pendingRefreshError = nil
        let alert = UIAlertController(title: "Refresh failed", message: "\(message) Showing the last available data.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showStatus(_ message: String, retry: Bool = false) {
        let label = UILabel()
        label.text = message
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        if retry {
            let button = UIButton(type: .system)
            button.setTitle("Try Again", for: .normal)
            button.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                Task { await self.viewModel.retry() }
            }, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        let background = UIView()
        background.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        let paddedWidth = stack.widthAnchor.constraint(lessThanOrEqualTo: background.widthAnchor, constant: -48)
        paddedWidth.priority = UILayoutPriority(999)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: background.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: background.centerYAnchor),
            paddedWidth
        ])
        tableView.backgroundView = background
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let id = self.tableView.item(at: indexPath), let row = rowsByID[id] else { return }
        router.showSquad(for: row.team, players: row.players)
    }
}
