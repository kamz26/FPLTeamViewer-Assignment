import Foundation
import OSLog

@MainActor
final class TeamsViewModel {
    struct TeamRowModel: Equatable, Identifiable {
        let team: Team
        let players: [Player]
        
        var id: Team.ID { team.id }
    }
    
    enum ViewState: Equatable {
        case idle
        case loading
        case empty
        case content([TeamRowModel])
        case failed(String)
    }
    
    var onChange: (() -> Void)?
    var onRefreshError: ((String) -> Void)?
    private(set) var state: ViewState = .idle { didSet { onChange?() } }
    
    private let repository: any LeagueRepository
    private let logger = Logger(subsystem: "com.seeclear.FPLTeamViewer", category: "Teams")
    private var isBusy = false
    private var operationWaiters: [CheckedContinuation<Void, Never>] = []
    
    init(repository: any LeagueRepository) {
        self.repository = repository
    }
    
    func load() async {
        guard case .idle = state, !isBusy else { return }
        isBusy = true
        defer { finishOperation() }
        state = .loading

        do {
            if let cached = try await repository.cachedSnapshot(), !Task.isCancelled {
                apply(cached)
            }
        } catch is CancellationError {
            state = .idle
            return
        } catch {
            logger.warning("Could not read cached teams: \(error.localizedDescription)")
        }
        guard !Task.isCancelled else {
            if case .loading = state { state = .idle }
            return
        }
        await fetchLatest()
    }
    
    func retry() async {
        guard case .failed = state else { return }
        state = .idle
        await load()
    }
    
    func refresh() async {
        if isBusy {
            await withCheckedContinuation { operationWaiters.append($0) }
            return
        }
        if case .idle = state {
            await load()
            return
        }
        isBusy = true
        defer { finishOperation() }
        await fetchLatest()
    }

    private func fetchLatest() async {
        do {
            let snapshot = try await repository.refresh()
            guard !Task.isCancelled else { return }
            apply(snapshot)
        } catch is CancellationError {
            if case .loading = state { state = .idle }
            return
        } catch {
            if case .content = state {
                onRefreshError?(Self.message(for: error))
            } else {
                state = .failed(Self.message(for: error))
            }
        }
    }

    private func finishOperation() {
        isBusy = false
        let waiters = operationWaiters
        operationWaiters.removeAll()
        waiters.forEach { $0.resume() }
    }
    
    private static func message(for error: Error) -> String {
        (error as? LocalizedError)?.errorDescription
        ?? "Football data could not be loaded. Check your connection and try again."
    }
    
    private func apply(_ snapshot: LeagueSnapshot) {
        guard !snapshot.teams.isEmpty else {
            state = .empty
            return
        }
        
        let playersByTeam = Dictionary(grouping: snapshot.players, by: \.teamID)
        let rows = snapshot.teams.map { team in
            TeamRowModel(team: team, players: playersByTeam[team.id, default: []])
        }
        state = .content(rows)
    }
}
