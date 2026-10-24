import SwiftUI
import DesignKit
import SRSKit

struct StudyScreen: View {
    var deck: Deck
    var onExit: () -> Void

    @EnvironmentObject private var reviewStore: ReviewStore
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme
    @State private var queue: [StudyCard] = []
    @State private var index = 0
    @State private var revealed: Bool

    init(
        deck: Deck,
        onExit: @escaping () -> Void,
        initiallyRevealed: Bool = false,
        previewQueue: [StudyCard]? = nil
    ) {
        self.deck = deck
        self.onExit = onExit
        _revealed = State(initialValue: initiallyRevealed)
        _queue = State(initialValue: previewQueue ?? [])
    }

    private var card: StudyCard? {
        queue.indices.contains(index) ? queue[index] : nil
    }

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(spacing: 16) {
            HStack(spacing: 10) {
                BackChip(label: text.tabCards, action: onExit)
                Spacer()
                LeafProgress(total: max(queue.count, 1), done: min(index, max(queue.count, 1)))
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)

            Spacer(minLength: 0)

            if let card {
                Button {
                    withAnimation(Motion.card) { revealed.toggle() }
                } label: {
                    FloatCard(padding: 26) {
                        VStack(spacing: 14) {
                            Text(deck.name)
                                .font(Typography.caption)
                                .foregroundStyle(t.inkSoft)

                            Text(inline(card.front))
                                .font(Typography.display(24))
                                .foregroundStyle(t.ink)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, minHeight: 90)

                            if revealed {
                                Divider().opacity(0.4)
                                Text(inline(card.back))
                                    .font(Typography.title)
                                    .foregroundStyle(t.success)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                            } else {
                                Text("\(index + 1) / \(queue.count)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                                    .foregroundStyle(t.inkSoft.opacity(0.8))
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 190)
                    }
                }
                .buttonStyle(.plain)
                .padding(.horizontal, Metrics.pad)
            } else {
                FloatCard {
                    VStack(spacing: 8) {
                        Text(text.nothingToStudy)
                            .font(Typography.headline)
                            .foregroundStyle(t.ink)
                        Text(text.done)
                            .font(Typography.caption)
                            .foregroundStyle(t.inkSoft)
                    }
                }
                .padding(.horizontal, Metrics.pad)
            }

            Spacer(minLength: 0)

            HStack(spacing: 10) {
                ratingButton(text.again, fill: t.surface, edge: t.sand, rating: .again, t: t)
                ratingButton(text.good, fill: t.accent, edge: t.accentEdge, rating: .good, t: t)
                ratingButton(text.easy, fill: t.surface, edge: t.success.opacity(0.5), rating: .easy, t: t)
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.bottom, 12)
            .opacity(card == nil ? 0.4 : 1)
            .disabled(card == nil)
        }
        .onAppear { fillQueueIfNeeded() }
    }

    private func fillQueueIfNeeded() {
        guard queue.isEmpty else { return }
        queue = reviewStore.queue(for: deck)
    }

    /// Card text carries `**bold**` around the filled blank, converted from the
    /// Anki HTML by the exporter.
    private func inline(_ string: String) -> AttributedString {
        (try? AttributedString(
            markdown: string,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(string)
    }

    private func ratingButton(
        _ label: String, fill: Color, edge: Color, rating: Rating, t: SceneTokens
    ) -> some View {
        Button(label) {
            if let card {
                reviewStore.record(card: card, deckID: deck.id.uuidString, rating: rating)
            }
            withAnimation(Motion.card) {
                if index + 1 < queue.count {
                    index += 1
                } else {
                    index = queue.count
                }
                revealed = false
            }
        }
        .buttonStyle(ChunkyButtonStyle(
            fill: fill, edge: edge, ink: t.ink, compact: true, fullWidth: true))
    }
}
