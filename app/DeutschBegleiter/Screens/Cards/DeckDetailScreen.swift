import SwiftUI
import DesignKit

struct DeckDetailScreen: View {
    var deck: Deck
    var onBack: () -> Void
    var onStudy: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme
    @State private var confirmingDelete = false

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(spacing: 16) {
            HStack {
                BackChip(label: text.back, action: onBack)
                Spacer()
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)

            FloatCard {
                VStack(alignment: .leading, spacing: 12) {
                    Text(deck.name)
                        .font(Typography.display(26))
                        .foregroundStyle(t.ink)

                    HStack(spacing: 6) {
                        Chip(deck.level.rawValue, tint: Color(hex: 0xD9F0C4))
                        Chip(deck.origin == .custom ? text.custom : text.predefined,
                             tint: Color(hex: 0xBFE0FF))
                    }

                    Text(deck.subtitle)
                        .font(Typography.caption)
                        .foregroundStyle(t.inkSoft)

                    Divider().opacity(0.4)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(deck.totalCount.formatted())
                            .font(Typography.display(28))
                            .foregroundStyle(t.ink)
                        Text(text.cardsCount)
                            .font(Typography.caption)
                            .foregroundStyle(t.inkSoft)
                        Spacer()
                        if deck.isPartial {
                            Text("\(deck.cards.count) \(text.preview)")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(t.inkSoft)
                        }
                    }
                }
            }
            .padding(.horizontal, Metrics.pad)

            VStack(spacing: 10) {
                Button {
                    onStudy()
                } label: {
                    Label(text.study, systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(ChunkyButtonStyle(
                    fill: t.accent, edge: t.accentEdge, ink: t.ink, fullWidth: true))
                .disabled(deck.cards.isEmpty)
                .opacity(deck.cards.isEmpty ? 0.5 : 1)

                if deck.isEditable {
                    HStack(spacing: 10) {
                        Button {
                            onEdit()
                        } label: {
                            Label(text.edit, systemImage: "pencil")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ChunkyButtonStyle(
                            fill: t.surface, edge: t.sand, ink: t.ink, compact: true, fullWidth: true))

                        Button(role: .destructive) {
                            confirmingDelete = true
                        } label: {
                            Label(text.delete, systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(ChunkyButtonStyle(
                            fill: t.surface, edge: t.error.opacity(0.6), ink: t.error,
                            compact: true, fullWidth: true))
                    }
                }
            }
            .padding(.horizontal, Metrics.pad)

            Spacer()
        }
        .confirmationDialog(text.delete, isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button(text.delete, role: .destructive, action: onDelete)
            Button(text.cancel, role: .cancel) {}
        }
    }
}
