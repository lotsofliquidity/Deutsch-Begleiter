import SwiftUI
import DesignKit

struct DeckLibraryScreen: View {
    @Binding var level: Level
    var onOpen: (Deck) -> Void
    var onNew: () -> Void

    @EnvironmentObject private var store: DeckStore
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(text.tabCards)
                    .font(Typography.display(30))
                    .foregroundStyle(t.ink)
                Spacer()
                Chip("\(store.decks.count)", symbol: "rectangle.on.rectangle.angled",
                     tint: Color(hex: 0xBFE0FF))
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)

            levelPicker(t)

            ScreenScroll {
                VStack(spacing: 10) {
                    let decks = store.decks(in: level)

                    if decks.isEmpty {
                        emptyState(t)
                    } else {
                        ForEach(decks) { deck in
                            Button { onOpen(deck) } label: {
                                DeckRow(deck: deck)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Button {
                        onNew()
                    } label: {
                        Label(text.newDeck, systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(ChunkyButtonStyle(
                        fill: t.accent, edge: t.accentEdge, ink: t.ink, fullWidth: true))
                    .padding(.top, 4)
                }
                .padding(.horizontal, Metrics.pad)
                .padding(.bottom, 24)
            }
        }
    }

    private func levelPicker(_ t: SceneTokens) -> some View {
        HStack(spacing: 6) {
            ForEach(Level.allCases) { candidate in
                let isOn = candidate == level
                Button {
                    level = candidate
                } label: {
                    VStack(spacing: 2) {
                        Text(candidate.rawValue)
                            .font(Typography.headline)
                        Text(countLabel(for: candidate))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .opacity(0.7)
                    }
                    .foregroundStyle(isOn ? t.ink : t.ink.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(isOn ? t.accent.opacity(0.92) : Color.clear)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(t.surface.opacity(0.92))
        )
        .padding(.horizontal, Metrics.pad)
        .animation(Motion.press, value: level)
    }

    private func countLabel(for level: Level) -> String {
        let decks = store.decks(in: level)
        let total = decks.reduce(0) { $0 + $1.totalCount }
        return total == 0 ? "—" : total.formatted()
    }

    private func emptyState(_ t: SceneTokens) -> some View {
        FloatCard {
            VStack(alignment: .leading, spacing: 6) {
                if level == .b1 {
                    Text(text.noB1)
                        .font(Typography.headline)
                        .foregroundStyle(t.ink)
                    Text(text.noB1Detail)
                        .font(Typography.caption)
                        .foregroundStyle(t.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(text.packMissing)
                        .font(Typography.headline)
                        .foregroundStyle(t.ink)
                    Text(text.packMissingDetail)
                        .font(Typography.caption)
                        .foregroundStyle(t.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct DeckRow: View {
    var deck: Deck
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        FloatCard(padding: 16) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(deck.name)
                            .font(Typography.headline)
                            .foregroundStyle(t.ink)
                        Chip(deck.origin == .custom ? text.custom : text.predefined,
                             tint: deck.origin == .custom ? Color(hex: 0xD9F0C4) : Color(hex: 0xBFE0FF))
                    }
                    Text(deck.subtitle)
                        .font(Typography.caption)
                        .foregroundStyle(t.inkSoft)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 1) {
                    Text(deck.totalCount.formatted())
                        .font(Typography.headline)
                        .foregroundStyle(t.ink)
                    Text(text.cardsCount)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(t.inkSoft)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(t.ink.opacity(0.35))
            }
        }
    }
}
