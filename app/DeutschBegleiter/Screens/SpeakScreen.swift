import SwiftUI
import DesignKit

struct SpeakScreen: View {
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme
    @State private var level: Double = 0

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(spacing: 0) {
            HStack {
                Chip(text.speaking, symbol: "waveform", tint: Color(hex: 0xBFE0FF))
                Spacer()
                Chip("Café · Perfekt", tint: Color(hex: 0xCDEBA0))
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 6)

            Spacer(minLength: 8)

            VStack(alignment: .leading, spacing: 10) {
                SpeechBubble("Guten Tag! Was darf es sein?", speaker: .tutor, speaks: true)
                SpeechBubble("Ich hätte gern einen Kaffee, bitte.", speaker: .you)
                SpeechBubble("Sehr gern. Möchten Sie auch etwas essen?", speaker: .tutor, speaks: true)
            }
            .padding(.horizontal, Metrics.pad)

            Spacer(minLength: 16)

            HStack(spacing: 14) {
                Dackel(mood: .listening)
                    .frame(width: 120, height: 60)
                SpeechOrb(level: level)
            }
            .frame(maxWidth: .infinity)

            Text(text.justStartTalking)
                .font(Typography.caption)
                .foregroundStyle(t.ink.opacity(0.65))
                .padding(.top, 6)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Metrics.pad)

            HStack(spacing: 10) {
                ForEach([text.hint, text.again, text.slower], id: \.self) { label in
                    Button(label) {}
                        .buttonStyle(ChunkyButtonStyle(
                            fill: t.surface, edge: t.sand, ink: t.ink, compact: true))
                }
            }
            .padding(.top, 18)
            .padding(.bottom, 10)
        }
        .task {
            // stand-in for the mic meter until SpeechKit lands
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: 0.9)) {
                    level = Double.random(in: 0.05...0.75)
                }
                try? await Task.sleep(for: .milliseconds(900))
            }
        }
    }
}
