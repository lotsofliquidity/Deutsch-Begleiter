import SwiftUI

/// Everything the meadow scene and the surfaces on top of it need.
/// Day and dusk are the same drawing with two token sets — never a grey dark mode.
public struct SceneTokens: Sendable {
    public let skyTop: Color
    public let skyBottom: Color
    public let hillFar: Color
    public let hillMid: Color
    public let hillNear: Color
    public let meadowShade: Color
    public let cloud: Color
    public let leafLight: Color
    public let leafMid: Color
    public let leafDark: Color
    public let bark: Color
    public let sand: Color
    public let clay: Color
    public let surface: Color
    public let surfaceSunken: Color
    public let ink: Color
    public let inkSoft: Color
    public let accent: Color
    public let accentEdge: Color
    public let success: Color
    public let error: Color
    public let sun: Color

    public static let day = SceneTokens(
        skyTop: Palette.skyZenith,
        skyBottom: Palette.skyHorizon,
        hillFar: Color(hex: 0xBCD9C0),
        hillMid: Color(hex: 0xA8CE9C),
        hillNear: Palette.meadow,
        meadowShade: Palette.meadowDeep,
        cloud: Palette.cloud,
        leafLight: Color(hex: 0xA9D08E),
        leafMid: Color(hex: 0x8CBF83),
        leafDark: Color(hex: 0x6B9E7A),
        bark: Palette.bark,
        sand: Palette.sand,
        clay: Palette.clay,
        surface: Palette.cream,
        surfaceSunken: Color(hex: 0xEEF4E4),
        ink: Palette.ink,
        inkSoft: Palette.inkSoft,
        accent: Palette.butter,
        accentEdge: Palette.butterEdge,
        success: Palette.teal,
        error: Palette.coral,
        sun: Color(hex: 0xFFE9A8)
    )

    public static let dusk = SceneTokens(
        skyTop: Color(hex: 0x3C4A7A),
        skyBottom: Color(hex: 0x8A82AD),
        hillFar: Color(hex: 0x4A5F72),
        hillMid: Color(hex: 0x3E6B63),
        hillNear: Color(hex: 0x4A7A55),
        meadowShade: Color(hex: 0x3D6448),
        cloud: Color(hex: 0xC9CBE0),
        leafLight: Color(hex: 0x5B8A6E),
        leafMid: Color(hex: 0x46705C),
        leafDark: Color(hex: 0x33544A),
        bark: Color(hex: 0x4A4033),
        sand: Color(hex: 0x7A6959),
        clay: Color(hex: 0x574B42),
        surface: Color(hex: 0x28332E),
        surfaceSunken: Color(hex: 0x1F2925),
        ink: Color(hex: 0xF2F5EE),
        inkSoft: Color(hex: 0xA8B5AB),
        accent: Color(hex: 0xFFD86E),
        accentEdge: Color(hex: 0xC9A63E),
        success: Color(hex: 0x4FC3AE),
        error: Color(hex: 0xF08A80),
        sun: Color(hex: 0xFFDFA0)
    )

    public static func resolve(_ scheme: ColorScheme) -> SceneTokens {
        scheme == .dark ? .dusk : .day
    }
}
