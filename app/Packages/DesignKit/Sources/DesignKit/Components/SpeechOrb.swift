import SwiftUI

/// The microphone as a soft living thing: rings expand with your voice, and the
/// core breathes while it waits.
public struct SpeechOrb: View {
    private var level: Double
    private var isListening: Bool
    @State private var breathe: CGFloat = 0
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(level: Double = 0, isListening: Bool = true) {
        self.level = max(0, min(1, level))
        self.isListening = isListening
    }

    public var body: some View {
        let t = SceneTokens.resolve(scheme)
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(t.success.opacity(0.28 - Double(i) * 0.07), lineWidth: 3)
                    .scaleEffect(1 + CGFloat(i) * 0.20 + CGFloat(level) * 0.16 + breathe * 0.04)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.85), t.sun, t.accent],
                        center: .init(x: 0.38, y: 0.30),
                        startRadius: 2,
                        endRadius: 118
                    )
                )
                .scaleEffect(1 + CGFloat(level) * 0.10 + breathe * 0.03)
                .overlay(
                    Circle().strokeBorder(t.success.opacity(0.55), lineWidth: 3)
                )
                .shadow(color: t.accent.opacity(0.40), radius: 26, y: 10)

            Image(systemName: isListening ? "waveform" : "pause.fill")
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(t.ink.opacity(0.55))
        }
        .frame(width: 190, height: 190)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(Motion.breathe.repeatForever(autoreverses: true)) {
                breathe = 1
            }
        }
        .animation(Motion.press, value: level)
        .accessibilityLabel(isListening ? "Hört zu" : "Pausiert")
    }
}

/// A spoken line. Cloud-white for the tutor, meadow-tinted for you.
public struct SpeechBubble: View {
    public enum Speaker { case tutor, you }

    private var text: String
    private var speaker: Speaker
    private var speaks: Bool
    @Environment(\.colorScheme) private var scheme

    public init(_ text: String, speaker: Speaker, speaks: Bool = false) {
        self.text = text
        self.speaker = speaker
        self.speaks = speaks
    }

    public var body: some View {
        let t = SceneTokens.resolve(scheme)
        HStack(alignment: .bottom, spacing: 8) {
            if speaker == .you { Spacer(minLength: 40) }

            HStack(spacing: 8) {
                Text(text)
                    .font(Typography.body)
                    .foregroundStyle(t.ink)
                if speaks && speaker == .tutor {
                    SpeakerWave(tint: t.success)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(speaker == .tutor ? t.surface : t.hillNear.opacity(0.9))
            )
            .shadow(color: t.leafMid.opacity(0.16), radius: 10, y: 4)

            if speaker == .tutor { Spacer(minLength: 40) }
        }
    }
}

struct SpeakerWave: View {
    var tint: Color
    @State private var on = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(tint.opacity(0.75))
                    .frame(width: 3, height: on ? CGFloat(6 + i * 4) : CGFloat(12 - i * 3))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) { on = true }
        }
    }
}
