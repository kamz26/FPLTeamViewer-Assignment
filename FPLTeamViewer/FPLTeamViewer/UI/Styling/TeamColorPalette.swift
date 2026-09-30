import UIKit

struct TeamColorPalette: Equatable, Sendable {
    let backgroundRGB: UInt32
    let foregroundRGB: UInt32

    var background: UIColor { UIColor(rgb: backgroundRGB) }
    var foreground: UIColor { UIColor(rgb: foregroundRGB) }

    static func resolve(shortName: String) -> TeamColorPalette {
        let key = shortName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()
        return palettes[key] ?? fallback
    }

    private static let fallback = TeamColorPalette(
        backgroundRGB: 0x5856D6,
        foregroundRGB: 0xFFFFFF
    )

    private static let palettes: [String: TeamColorPalette] = [
        "ARS": .init(backgroundRGB: 0xEF0107, foregroundRGB: 0xFFFFFF),
        "AVL": .init(backgroundRGB: 0x670E36, foregroundRGB: 0xFFFFFF),
        "BOU": .init(backgroundRGB: 0xDA291C, foregroundRGB: 0xFFFFFF),
        "BRE": .init(backgroundRGB: 0xE30613, foregroundRGB: 0xFFFFFF),
        "BHA": .init(backgroundRGB: 0x0057B8, foregroundRGB: 0xFFFFFF),
        "CHE": .init(backgroundRGB: 0x034694, foregroundRGB: 0xFFFFFF),
        "COV": .init(backgroundRGB: 0x69B3E7, foregroundRGB: 0x132257),
        "CRY": .init(backgroundRGB: 0x1B458F, foregroundRGB: 0xFFFFFF),
        "EVE": .init(backgroundRGB: 0x003399, foregroundRGB: 0xFFFFFF),
        "FUL": .init(backgroundRGB: 0x000000, foregroundRGB: 0xFFFFFF),
        "HUL": .init(backgroundRGB: 0xF5A12D, foregroundRGB: 0x161616),
        "IPS": .init(backgroundRGB: 0x3A64A3, foregroundRGB: 0xFFFFFF),
        "LEE": .init(backgroundRGB: 0xFFCD00, foregroundRGB: 0x1D428A),
        "LIV": .init(backgroundRGB: 0xC8102E, foregroundRGB: 0xFFFFFF),
        "MCI": .init(backgroundRGB: 0x6CABDD, foregroundRGB: 0x132257),
        "MUN": .init(backgroundRGB: 0xDA291C, foregroundRGB: 0xFFFFFF),
        "NEW": .init(backgroundRGB: 0x241F20, foregroundRGB: 0xFFFFFF),
        "NFO": .init(backgroundRGB: 0xDD0000, foregroundRGB: 0xFFFFFF),
        "TOT": .init(backgroundRGB: 0x132257, foregroundRGB: 0xFFFFFF),
        "SUN": .init(backgroundRGB: 0xEB172B, foregroundRGB: 0xFFFFFF)
    ]
}

private extension UIColor {
    convenience init(rgb: UInt32) {
        let red = CGFloat((rgb >> 16) & 0xFF) / 255
        let green = CGFloat((rgb >> 8) & 0xFF) / 255
        let blue = CGFloat(rgb & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
