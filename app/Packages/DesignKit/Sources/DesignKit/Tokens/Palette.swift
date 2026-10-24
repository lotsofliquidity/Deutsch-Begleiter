import SwiftUI

public extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Raw hues sampled from the reference artwork.
enum Palette {
    static let skyZenith = Color(hex: 0xA7D6FE)
    static let skyHorizon = Color(hex: 0xD6EEFF)
    static let cloud = Color(hex: 0xF7FBFE)
    static let meadow = Color(hex: 0xDEF28D)
    static let meadowDeep = Color(hex: 0xC9E070)
    static let sage = Color(hex: 0x9AC593)
    static let leaf = Color(hex: 0x6FA97B)
    static let sand = Color(hex: 0xF1CC91)
    static let clay = Color(hex: 0xD9A96A)
    static let bark = Color(hex: 0x9C8967)
    static let ink = Color(hex: 0x2F3B33)
    static let inkSoft = Color(hex: 0x67766B)
    static let butter = Color(hex: 0xFFD86E)
    static let butterEdge = Color(hex: 0xE0B84A)
    static let teal = Color(hex: 0x3FA796)
    static let coral = Color(hex: 0xE4736B)
    static let cream = Color(hex: 0xFFFDF7)
}

/// Grammatical gender is a mnemonic, not decoration: the same four colours
/// appear on every table, card and correction in the app.
public enum NounColor {
    public static let der = Color(hex: 0xD9534C)
    public static let die = Color(hex: 0xD9538A)
    public static let das = Color(hex: 0x4A9E62)
    public static let plural = Color(hex: 0x8E6FC4)
}
