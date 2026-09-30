import XCTest
@testable import FPLTeamViewer

final class TeamColorPaletteTests: XCTestCase {
    func testResolvesPredefinedAndFallbackColors() {
        let arsenal = TeamColorPalette.resolve(shortName: "ARS")
        let fallback = TeamColorPalette.resolve(shortName: "UNKNOWN")

        XCTAssertEqual(arsenal.backgroundRGB, 0xEF0107)
        XCTAssertEqual(arsenal.foregroundRGB, 0xFFFFFF)
        XCTAssertEqual(fallback.backgroundRGB, 0x5856D6)
    }
}
