import XCTest
@testable import FPLTeamViewer

final class DecodingAndMappingTests: XCTestCase {
    func testDecodesAndMapsBootstrapPayload() throws {
        let decoded = try JSONDecoder().decode(BootstrapDTO.self, from: Fixtures.json)
        let snapshot = try LeagueMapper().map(decoded)

        XCTAssertEqual(decoded.teams.count, 2)
        XCTAssertEqual(decoded.elements.count, 6)
        XCTAssertEqual(snapshot.teams.map(\.name), ["Alpha FC", "Beta FC"])
        XCTAssertEqual(snapshot.players.first?.price, Decimal(string: "4.5"))
        XCTAssertEqual(snapshot.players.first?.position, .goalkeeper)
    }
}
