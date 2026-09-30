import UIKit

@MainActor
final class DiffableTableView<Section: Hashable & Sendable, Item: Hashable & Sendable>: UITableView {
    private var source: UITableViewDiffableDataSource<Section, Item>!

    init(style: UITableView.Style, cell: @escaping (UITableView, IndexPath, Item) -> UITableViewCell) {
        super.init(frame: .zero, style: style)
        source = UITableViewDiffableDataSource(tableView: self, cellProvider: cell)
    }

    required init?(coder: NSCoder) { fatalError("Use init(style:cell:)") }

    func apply(_ sections: [(Section, [Item])], reconfiguring changedItems: [Item] = []) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        let previous = Set(source.snapshot().itemIdentifiers)
        for (section, items) in sections {
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        let retained = Set(snapshot.itemIdentifiers).intersection(previous)
        snapshot.reconfigureItems(changedItems.filter { retained.contains($0) })
        source.apply(snapshot, animatingDifferences: !previous.isEmpty)
    }

    func item(at indexPath: IndexPath) -> Item? {
        source.itemIdentifier(for: indexPath)
    }

    func section(at index: Int) -> Section? {
        let sections = source.snapshot().sectionIdentifiers
        return sections.indices.contains(index) ? sections[index] : nil
    }
}
