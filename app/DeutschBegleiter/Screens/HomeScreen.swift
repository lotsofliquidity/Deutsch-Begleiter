import SwiftUI
import DesignKit

struct HomeScreen: View {
    @EnvironmentObject private var store: DeckStore
    @EnvironmentObject private var reviewStore: ReviewStore
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme

    private var packTotal: Int {
        store.decks
            .filter { $0.origin == .predefined }
            .reduce(0) { $0 + $1.totalCount }
    }

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        ScreenScroll {
            VStack(alignment: .leading, spacing: 16) {
                header(t)

                FloatCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text(text.dueToday)
                                .font(Typography.title)
                                .foregroundStyle(t.ink)
                            Spacer()
                            Chip("14", symbol: "flame.fill", tint: t.accent)
                        }

                        VStack(spacing: 8) {
                            DueRow(symbol: "arrow.triangle.2.circlepath",
                                   label: text.reviews, detail: text.fromReviewLog,
                                   value: "\(reviewStore.dueCount(for: store.decks))",
                                   tint: t.error)
                            DueRow(symbol: "rectangle.on.rectangle.angled",
                                   label: text.cards, detail: "A1 + A2",
                                   value: packTotal.formatted(), tint: Color(hex: 0x5B9BD5))
                            DueRow(symbol: "text.bubble",
                                   label: text.speaking, detail: "Café · Perfekt",
                                   value: "3 min", tint: t.success)
                        }

                        LeafProgress(total: 10, done: 6)

                        Button(text.letsGo) {}
                            .buttonStyle(ChunkyButtonStyle(
                                fill: t.accent, edge: t.accentEdge, ink: t.ink, fullWidth: true))
                    }
                }

                FloatCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(text.sayItOutLoud)
                            .font(Typography.headline)
                            .foregroundStyle(t.ink)
                        Text(text.sayItOutLoudDetail)
                            .font(Typography.body)
                            .foregroundStyle(t.inkSoft)
                        HStack(spacing: 8) {
                            Chip("Perfekt", symbol: "clock.arrow.circlepath",
                                 tint: Color(hex: 0xBFE0FF))
                            Chip("Dativ", symbol: "arrow.turn.up.right",
                                 tint: Color(hex: 0xD9F0C4))
                        }
                    }
                }

                Spacer(minLength: 220)
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)
        }
        .overlay(alignment: .bottomTrailing) {
            Dackel(mood: .happy)
                .frame(width: 200, height: 100)
                .padding(.trailing, 20)
                .padding(.bottom, 4)
        }
    }

    private func header(_ t: SceneTokens) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(text.hello)
                    .font(Typography.display(32))
                    .foregroundStyle(t.ink)
                Text("A2.1 · \(text.unitLabel) 6")
                    .font(Typography.caption)
                    .foregroundStyle(t.ink.opacity(0.6))
            }
            Spacer()
            Chip("\(text.streak) 14", symbol: "leaf.fill", tint: Color(hex: 0xCDEBA0))
        }
    }
}

private struct DueRow: View {
    var symbol: String
    var label: String
    var detail: String
    var value: String
    var tint: Color
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(Circle().fill(tint.opacity(0.16)))

            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(Typography.body).foregroundStyle(t.ink)
                Text(detail).font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(t.inkSoft)
            }

            Spacer()

            Text(value).font(Typography.headline).foregroundStyle(t.ink)
        }
        .padding(.vertical, 2)
    }
}
