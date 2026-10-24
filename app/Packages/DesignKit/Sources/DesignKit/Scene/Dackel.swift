import SwiftUI

/// The mascot. Drawn from the same four-tone flat vocabulary as the scene, so it
/// sits on the meadow without needing a sprite sheet.
public struct Dackel: View {
    public enum Mood: Sendable {
        case idle, listening, happy
    }

    private var mood: Mood
    private var animates: Bool
    @State private var blink = false
    @State private var bob: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(mood: Mood = .idle, animates: Bool = true) {
        self.mood = mood
        self.animates = animates
    }

    public var body: some View {
        Canvas { ctx, size in
            draw(&ctx, size)
        }
        .offset(y: reduceMotion ? 0 : bob)
        .task(id: animates) {
            guard animates, !reduceMotion, !RenderMode.isRendering else { return }
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                bob = -3
            }
            while !Task.isCancelled {
                blink = true
                try? await Task.sleep(for: .milliseconds(120))
                blink = false
                try? await Task.sleep(for: .seconds(3.4))
            }
        }
        .accessibilityLabel("Dackel")
    }

    private func draw(_ ctx: inout GraphicsContext, _ size: CGSize) {
        let s = min(size.width / 128, size.height / 60)
        let ox = (size.width - 128 * s) / 2
        let oy = (size.height - 60 * s) / 2

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: ox + x * s, y: oy + y * s)
        }

        func round(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat,
                   _ r: CGFloat, _ color: Color) {
            let rect = CGRect(origin: p(x, y), size: CGSize(width: w * s, height: h * s))
            ctx.fill(
                Path(roundedRect: rect, cornerRadius: r * s),
                with: .color(color)
            )
        }

        let fur = Color(hex: 0xC98F5B)
        let furDark = Color(hex: 0xA9714A)
        let cream = Color(hex: 0xF3DFC0)
        let ink = Color(hex: 0x4A3A2E)

        // tail
        var tail = Path()
        tail.move(to: p(22, 36))
        tail.addQuadCurve(to: p(4, 14), control: p(10, 32))
        tail.addLine(to: p(8, 11))
        tail.addQuadCurve(to: p(28, 30), control: p(14, 22))
        tail.closeSubpath()
        ctx.fill(tail, with: .color(furDark))

        // far legs, tucked behind the body
        round(34, 40, 9, 18, 4.5, furDark)
        round(80, 40, 9, 18, 4.5, furDark)

        // body
        round(18, 24, 76, 22, 11, fur)

        // chest
        round(72, 34, 24, 12, 6, cream)

        // near legs
        round(28, 42, 10, 17, 5, fur)
        round(74, 42, 10, 17, 5, fur)

        // neck, joining body to head
        round(82, 26, 20, 20, 9, fur)

        // head
        let head = CGRect(origin: p(86, 8), size: CGSize(width: 32 * s, height: 32 * s))
        ctx.fill(Path(ellipseIn: head), with: .color(fur))

        // snout
        round(102, 26, 20, 14, 7, fur)
        round(108, 29, 13, 9, 4.5, cream)

        // ear hangs from the side of the head, perked when listening
        let earAngle: CGFloat = mood == .listening ? -26 : 14
        var ear = Path()
        ear.addPath(
            Path(roundedRect: CGRect(x: -6 * s, y: -12 * s, width: 12 * s, height: 25 * s),
                 cornerRadius: 6 * s)
        )
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: p(93, 26).x, y: p(93, 26).y)
        transform = transform.rotated(by: earAngle * .pi / 180)
        ctx.fill(ear.applying(transform), with: .color(furDark))

        // nose
        let nose = CGRect(origin: p(118, 31), size: CGSize(width: 6.5 * s, height: 6.5 * s))
        ctx.fill(Path(ellipseIn: nose), with: .color(ink))

        // eye
        if blink {
            var arc = Path()
            arc.move(to: p(99, 24))
            arc.addQuadCurve(to: p(106, 24), control: p(102.5, 20))
            ctx.stroke(arc, with: .color(ink),
                       style: StrokeStyle(lineWidth: 2.2 * s, lineCap: .round))
        } else {
            let eye = CGRect(origin: p(99, 20), size: CGSize(width: 6.5 * s, height: 6.5 * s))
            ctx.fill(Path(ellipseIn: eye), with: .color(ink))
            let glint = CGRect(origin: p(100.6, 21.4), size: CGSize(width: 2.2 * s, height: 2.2 * s))
            ctx.fill(Path(ellipseIn: glint), with: .color(.white.opacity(0.9)))
        }
    }
}
