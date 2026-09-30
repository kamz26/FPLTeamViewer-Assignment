import Foundation

enum MappingError: Error {
    case unknownPosition(Int)
}

struct LeagueMapper: Sendable {
    func map(_ dto: BootstrapDTO) throws -> LeagueSnapshot {
        let teams = dto.teams
            .map { Team(id: $0.id, name: $0.name, shortName: $0.shortName) }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        let players = try dto.elements.map { playerDTO -> Player in
            guard let position = Position(rawValue: playerDTO.elementType) else {
                throw MappingError.unknownPosition(playerDTO.elementType)
            }

            return Player(
                id: playerDTO.id,
                teamID: playerDTO.team,
                displayName: playerDTO.webName,
                position: position,
                priceTenths: playerDTO.nowCost,
                totalPoints: playerDTO.totalPoints
            )
        }

        return LeagueSnapshot(teams: teams, players: players)
    }
}
