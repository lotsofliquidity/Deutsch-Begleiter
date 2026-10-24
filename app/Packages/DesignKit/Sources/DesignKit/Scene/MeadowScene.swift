import SwiftUI

/// The meadow is drawn, not photographed: sky bands, hill silhouettes, tree
/// clusters and drifting clouds. No image assets, so it scales to any screen and
/// re-tints for dusk.
public struct MeadowScene: View {
    /// Fraction of the height where the horizon sits.
    private var horizon: CGFloat
    private var showsTrees: Bool
    private var animates: Bool
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(horizon: CGFloat = 0.62, showsTrees: Bool = true, animates: Bool = true) {
        self.horizon = horizon
        self.showsTrees = showsTrees
        self.animates = animates
    }

    public var body: some View {
        let t = SceneTokens.resolve(scheme)
        ZStack {
            LinearGradient(
                colors: [t.skyTop, t.skyBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            if showsTrees {
                TreeLine(tokens: t, horizon: horizon)
            }

            HillBands(tokens: t, horizon: horizon)

            CloudLayer(tint: t.cloud, animates: animates && !reduceMotion)
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

private struct HillBands: View {
    var tokens: SceneTokens
    var horizon: CGFloat

    private struct Band {
        let dy: CGFloat
        let amp: CGFloat
        let phase: CGFloat
        let color: Color
    }

    var body: some View {
        Canvas { ctx, size in
            let h = size.height
            let y = h * horizon

            let bands: [Band] = [
                .init(dy: -0.010, amp: 0.013, phase: 0.35, color: tokens.hillFar),
                .init(dy: 0.045, amp: 0.017, phase: 0.62, color: tokens.hillMid),
                .init(dy: 0.110, amp: 0.017, phase: 0.80, color: tokens.meadowShade),
                .init(dy: 0.150, amp: 0.017, phase: 0.80, color: tokens.hillNear)
            ]

            for band in bands {
                ctx.fill(
                    path(size: size, crest: y + h * band.dy, amp: h * band.amp, phase: band.phase),
                    with: .color(band.color)
                )
            }
        }
    }

    private func path(size: CGSize, crest: CGFloat, amp: CGFloat, phase: CGFloat) -> Path {
        let w = size.width
        let h = size.height
        var p = Path()
        p.move(to: CGPoint(x: 0, y: h))
        p.addLine(to: CGPoint(x: 0, y: crest + amp * sin(phase * .pi * 2)))
        p.addCurve(
            to: CGPoint(x: w * 0.52, y: crest - amp * 0.55),
            control1: CGPoint(x: w * 0.18, y: crest - amp * 2.0),
            control2: CGPoint(x: w * 0.33, y: crest + amp * 1.2)
        )
        p.addCurve(
            to: CGPoint(x: w, y: crest + amp * 0.30),
            control1: CGPoint(x: w * 0.72, y: crest - amp * 1.7),
            control2: CGPoint(x: w * 0.88, y: crest + amp * 1.3)
        )
        p.addLine(to: CGPoint(x: w, y: h))
        p.closeSubpath()
        return p
    }
}

private struct TreeLine: View {
    var tokens: SceneTokens
    var horizon: CGFloat

    /// x as a fraction of width, size as a fraction of the shorter screen edge.
    /// Clustered at the edges so the middle stays quiet behind the UI.
    private let trees: [(x: CGFloat, scale: CGFloat)] = [
        (-0.05, 0.44), (0.04, 0.56), (0.13, 0.36), (0.21, 0.22),
        (0.79, 0.20), (0.87, 0.34), (0.95, 0.52), (1.04, 0.40)
    ]

    var body: some View {
        GeometryReader { geo in
            let base = min(geo.size.width, geo.size.height)
            let baseY = geo.size.height * (horizon + 0.03)

            ForEach(Array(trees.enumerated()), id: \.offset) { _, tree in
                let height = base * tree.scale
                Tree(tokens: tokens)
                    .frame(width: height * 0.78, height: height)
                    .position(
                        x: geo.size.width * tree.x,
                        y: baseY - height * 0.5
                    )
            }
        }
        .allowsHitTesting(false)
    }
}

private struct Tree: View {
    var tokens: SceneTokens

    var body: some View {
        Canvas { ctx, size in
            // everything measured against the tree's own height so the canopy
            // keeps its shape at any frame size
            let u = size.height
            let cx = size.width / 2

            func circle(_ dx: CGFloat, _ dy: CGFloat, _ r: CGFloat, _ color: Color) {
                let rect = CGRect(
                    x: cx + (dx - r / 2) * u,
                    y: (dy - r / 2) * u,
                    width: r * u,
                    height: r * u
                )
                ctx.fill(Path(ellipseIn: rect), with: .color(color))
            }

            var trunk = Path()
            trunk.move(to: CGPoint(x: cx - 0.050 * u, y: u))
            trunk.addQuadCurve(
                to: CGPoint(x: cx - 0.028 * u, y: 0.50 * u),
                control: CGPoint(x: cx - 0.034 * u, y: 0.74 * u)
            )
            trunk.addLine(to: CGPoint(x: cx + 0.028 * u, y: 0.50 * u))
            trunk.addQuadCurve(
                to: CGPoint(x: cx + 0.050 * u, y: u),
                control: CGPoint(x: cx + 0.034 * u, y: 0.74 * u)
            )
            trunk.closeSubpath()
            ctx.fill(trunk, with: .color(tokens.bark))

            circle(0.00, 0.30, 0.62, tokens.leafDark)
            circle(-0.25, 0.27, 0.40, tokens.leafDark)
            circle(0.25, 0.26, 0.38, tokens.leafDark)

            circle(0.02, 0.24, 0.50, tokens.leafMid)
            circle(-0.19, 0.20, 0.34, tokens.leafMid)

            circle(-0.04, 0.18, 0.36, tokens.leafLight)
        }
    }
}

private struct CloudLayer: View {
    var tint: Color
    var animates: Bool

    @State private var drift: CGFloat = 0

    /// y as a fraction of screen height, scale, drift speed, start position
    private let clouds: [(y: CGFloat, scale: CGFloat, speed: CGFloat, offset: CGFloat)] = [
        (0.075, 0.90, 1.0, 0.10),
        (0.150, 0.58, 0.7, 0.42),
        (0.045, 0.46, 1.3, 0.74),
        (0.215, 0.38, 0.9, 0.26),
        (0.115, 0.72, 0.6, 0.60)
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(clouds.enumerated()), id: \.offset) { _, c in
                let width = geo.size.width * 0.44 * c.scale
                CloudShape()
                    .fill(tint)
                    .frame(width: width, height: width * 0.42)
                    .position(
                        x: geo.size.width * wrap(c.offset + drift * c.speed),
                        y: geo.size.height * c.y
                    )
                    .opacity(0.96)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            guard animates else { return }
            withAnimation(.linear(duration: 240).repeatForever(autoreverses: false)) {
                drift = 1
            }
        }
    }

    /// Wraps around the screen edge without a jump.
    private func wrap(_ v: CGFloat) -> CGFloat {
        let x = v - floor(v)
        return x * 1.4 - 0.2
    }
}

public struct CloudShape: Shape {
    public init() {}

    public func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var p = Path()

        p.addEllipse(in: CGRect(x: w * 0.00, y: h * 0.34, width: w * 0.42, height: h * 0.62))
        p.addEllipse(in: CGRect(x: w * 0.20, y: h * 0.06, width: w * 0.40, height: h * 0.80))
        p.addEllipse(in: CGRect(x: w * 0.50, y: h * 0.24, width: w * 0.38, height: h * 0.70))
        p.addRoundedRect(
            in: CGRect(x: w * 0.06, y: h * 0.52, width: w * 0.88, height: h * 0.44),
            cornerSize: CGSize(width: h * 0.22, height: h * 0.22)
        )
        return p
    }
}
