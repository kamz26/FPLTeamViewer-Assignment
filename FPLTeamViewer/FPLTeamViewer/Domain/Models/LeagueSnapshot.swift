import Foundation

struct LeagueSnapshot: Codable, Equatable, Sendable {
    let teams: [Team]
    let players: [Player]
}

struct Team: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: Int
    let name: String
    let shortName: String
}

struct Player: Codable, Equatable, Hashable, Identifiable, Sendable {
    let id: Int
    let teamID: Int
    let displayName: String
    let position: Position
    let priceTenths: Int
    let totalPoints: Int

    var price: Decimal {
        Decimal(priceTenths) / 10
    }
}

enum Position: Int, Codable, CaseIterable, Sendable {
    case goalkeeper = 1
    case defender = 2
    case midfielder = 3
    case forward = 4

    var title: String {
        switch self {
        case .goalkeeper: "Goalkeepers"
        case .defender: "Defenders"
        case .midfielder: "Midfielders"
        case .forward: "Forwards"
        }
    }

    var shortTitle: String {
        switch self {
        case .goalkeeper: "GKP"
        case .defender: "DEF"
        case .midfielder: "MID"
        case .forward: "FWD"
        }
    }
}
