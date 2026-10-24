import SwiftUI

public enum Metrics {
    public static let cardRadius: CGFloat = 26
    public static let buttonRadius: CGFloat = 22
    public static let pad: CGFloat = 20
    public static let gap: CGFloat = 12
    /// Height reserved for the floating tab bar.
    public static let tabBarClearance: CGFloat = 92
}

public enum Typography {
    public static func display(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    public static let title = Font.system(size: 24, weight: .bold, design: .rounded)
    public static let headline = Font.system(size: 19, weight: .bold, design: .rounded)
    public static let body = Font.system(size: 16, weight: .medium, design: .rounded)
    public static let caption = Font.system(size: 13, weight: .semibold, design: .rounded)
}

public enum Motion {
    public static let press = Animation.spring(response: 0.22, dampingFraction: 0.6)
    public static let card = Animation.spring(response: 0.35, dampingFraction: 0.72)
    public static let appear = Animation.spring(response: 0.45, dampingFraction: 0.8)
    public static let breathe = Animation.easeInOut(duration: 2.4)
}
