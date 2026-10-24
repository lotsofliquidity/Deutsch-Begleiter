import SwiftUI

/// A surface that presses into its own bottom edge. This is what makes the
/// style feel like a toy rather than a form.
public struct ChunkyButtonStyle: ButtonStyle {
    private var fill: Color
    private var edge: Color
    private var ink: Color
    private var compact: Bool
    private var fullWidth: Bool

    public init(fill: Color, edge: Color, ink: Color, compact: Bool = false, fullWidth: Bool = false) {
        self.fill = fill
        self.edge = edge
        self.ink = ink
        self.compact = compact
        self.fullWidth = fullWidth
    }

    public func makeBody(configuration: Configuration) -> some View {
        let radius = compact ? 16 : Metrics.buttonRadius
        let depth: CGFloat = compact ? 3 : 5

        return configuration.label
            .font(compact ? Typography.caption : Typography.headline)
            .foregroundStyle(ink)
            .padding(.horizontal, compact ? 14 : 26)
            .padding(.vertical, compact ? 8 : 15)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(fill))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(edge.opacity(0.35), lineWidth: 2)
            )
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(edge)
                    .offset(y: depth)
            )
            .offset(y: configuration.isPressed ? depth : 0)
            .animation(Motion.press, value: configuration.isPressed)
    }
}

/// Floating card: soft ambient shadow tinted with the scene's leaf colour, never black.
public struct FloatCard<Content: View>: View {
    private var padding: CGFloat
    private var content: Content
    @Environment(\.colorScheme) private var scheme

    public init(padding: CGFloat = Metrics.pad, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        let t = SceneTokens.resolve(scheme)
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: Metrics.cardRadius, style: .continuous)
                    .fill(t.surface)
            )
            .shadow(color: t.leafMid.opacity(0.20), radius: 18, x: 0, y: 8)
            .shadow(color: t.leafDark.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

/// Progress is a row of leaves filling in, not a bar.
public struct LeafProgress: View {
    private var total: Int
    private var done: Int
    @Environment(\.colorScheme) private var scheme

    public init(total: Int, done: Int) {
        self.total = max(total, 1)
        self.done = done
    }

    public var body: some View {
        let t = SceneTokens.resolve(scheme)
        HStack(spacing: 6) {
            ForEach(0..<total, id: \.self) { i in
                LeafShape()
                    .fill(i < done ? t.success : t.surfaceSunken)
                    .frame(width: 13, height: 16)
                    .rotationEffect(.degrees(-12))
                    .scaleEffect(i < done ? 1 : 0.86)
            }
        }
        .animation(Motion.card, value: done)
        .accessibilityElement()
        .accessibilityLabel("Fortschritt")
        .accessibilityValue("\(done) von \(total)")
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX + rect.width * 0.15, y: rect.midY)
        )
        p.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX - rect.width * 0.15, y: rect.midY)
        )
        p.closeSubpath()
        return p
    }
}

/// Small rounded label used for streaks, tags and unit chips.
public struct Chip: View {
    private var text: String
    private var symbol: String?
    private var tint: Color
    @Environment(\.colorScheme) private var scheme

    public init(_ text: String, symbol: String? = nil, tint: Color? = nil) {
        self.text = text
        self.symbol = symbol
        if let tint {
            self.tint = tint
        } else {
            self.tint = Palette.butter
        }
    }

    public var body: some View {
        let t = SceneTokens.resolve(scheme)
        HStack(spacing: 5) {
            if let symbol {
                Image(systemName: symbol).font(.system(size: 12, weight: .bold))
            }
            Text(text).font(Typography.caption)
        }
        .foregroundStyle(t.ink)
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
        .background(Capsule().fill(tint.opacity(0.85)))
    }
}
