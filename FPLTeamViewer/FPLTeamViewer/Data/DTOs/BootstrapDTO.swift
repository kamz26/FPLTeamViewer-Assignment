import Foundation

struct BootstrapDTO: Decodable, Sendable {
    let teams: [TeamDTO]
    let elements: [PlayerDTO]
}

struct TeamDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let shortName: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case shortName = "short_name"
    }
}

struct PlayerDTO: Decodable, Sendable {
    let id: Int
    let team: Int
    let webName: String
    let elementType: Int
    let nowCost: Int
    let totalPoints: Int

    enum CodingKeys: String, CodingKey {
        case id, team
        case webName = "web_name"
        case elementType = "element_type"
        case nowCost = "now_cost"
        case totalPoints = "total_points"
    }
}
