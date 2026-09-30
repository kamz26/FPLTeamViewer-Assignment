import Foundation

@MainActor
final class SquadViewModel {
    struct Section: Equatable, Identifiable {
        let position: Position
        let players: [Player]

        var id: Position { position }
    }

    enum ViewState: Equatable {
        case empty(searchText: String)
        case content([Section])
    }

    let team: Team
    var onChange: (() -> Void)?
    var query = "" {
        didSet {
            guard query != oldValue else { return }
            state = Self.makeState(query: query, players: allPlayers)
        }
    }
    private(set) var state: ViewState { didSet { onChange?() } }

    private let allPlayers: [Player]

    init(team: Team, players: [Player]) {
        self.team = team
        allPlayers = players
        state = Self.makeState(query: "", players: players)
    }

    private static func makeState(query: String, players: [Player]) -> ViewState {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = normalizedQuery.isEmpty
            ? players
            : players.filter {
                $0.displayName.localizedCaseInsensitiveContains(normalizedQuery)
            }

        let sections = Position.allCases.compactMap { position in
            let players = filtered
                .filter { $0.position == position }
                .sorted {
                    if $0.totalPoints == $1.totalPoints {
                        return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
                    }
                    return $0.totalPoints > $1.totalPoints
                }
            return players.isEmpty ? nil : Section(position: position, players: players)
        }

        return sections.isEmpty
            ? .empty(searchText: query)
            : .content(sections)
    }

}
