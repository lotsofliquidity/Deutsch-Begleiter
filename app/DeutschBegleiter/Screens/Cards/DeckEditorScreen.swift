import SwiftUI
import DesignKit

struct DeckEditorScreen: View {
    var existing: Deck?
    var onSave: (Deck) -> Void
    var onCancel: () -> Void

    @EnvironmentObject private var store: DeckStore
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme

    @State private var draft: Deck
    @State private var front = ""
    @State private var back = ""
    @State private var pasted = ""
    @State private var showingPaste = false
    @State private var nameMissing = false

    init(existing: Deck?, onSave: @escaping (Deck) -> Void, onCancel: @escaping () -> Void) {
        self.existing = existing
        self.onSave = onSave
        self.onCancel = onCancel
        _draft = State(initialValue: existing ?? Deck(
            name: "",
            level: .a1,
            origin: .custom,
            subtitle: "",
            catalogueCount: 0,
            cards: []
        ))
    }

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(spacing: 14) {
            HStack {
                BackChip(label: text.cancel, action: onCancel)
                Spacer()
                Button(text.done) { save() }
                    .buttonStyle(ChunkyButtonStyle(
                        fill: t.accent, edge: t.accentEdge, ink: t.ink, compact: true))
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)

            ScreenScroll {
                VStack(alignment: .leading, spacing: 12) {
                    FloatCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(text.deckName)
                                .font(Typography.caption)
                                .foregroundStyle(t.inkSoft)
                            PlainField(placeholder: "A1 · Wetter", text: $draft.name)

                            if nameMissing {
                                Text(text.deckNameRequired)
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                                    .foregroundStyle(t.error)
                            }

                            Text(text.level)
                                .font(Typography.caption)
                                .foregroundStyle(t.inkSoft)
                                .padding(.top, 2)

                            HStack(spacing: 6) {
                                ForEach(Level.allCases) { candidate in
                                    let isOn = candidate == draft.level
                                    Button {
                                        draft.level = candidate
                                    } label: {
                                        Text(candidate.rawValue)
                                            .font(Typography.caption)
                                            .foregroundStyle(isOn ? t.ink : t.ink.opacity(0.5))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(isOn ? t.accent.opacity(0.9) : t.surfaceSunken)
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    FloatCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(text.cardsCount.prefix(1).uppercased())\(text.cardsCount.dropFirst()) · \(draft.cards.count)")
                                .font(Typography.headline)
                                .foregroundStyle(t.ink)

                            ForEach(draft.cards) { card in
                                HStack(spacing: 8) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(card.front)
                                            .font(Typography.body)
                                            .foregroundStyle(t.ink)
                                        Text(card.back)
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundStyle(t.inkSoft)
                                    }
                                    Spacer(minLength: 6)
                                    Button {
                                        draft.cards.removeAll { $0.id == card.id }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundStyle(t.error.opacity(0.8))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.vertical, 3)
                            }

                            Divider().opacity(0.4)

                            PlainField(placeholder: text.front, text: $front)
                            PlainField(placeholder: text.backSide, text: $back)

                            Button {
                                addCard()
                            } label: {
                                Label(text.addCard, systemImage: "plus")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(ChunkyButtonStyle(
                                fill: t.surface, edge: t.sand, ink: t.ink,
                                compact: true, fullWidth: true))
                            .disabled(front.isEmpty || back.isEmpty)
                            .opacity(front.isEmpty || back.isEmpty ? 0.45 : 1)
                        }
                    }

                    FloatCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Button {
                                withAnimation(Motion.card) { showingPaste.toggle() }
                            } label: {
                                HStack {
                                    Text(text.pasteTSV)
                                        .font(Typography.headline)
                                        .foregroundStyle(t.ink)
                                    Spacer()
                                    Image(systemName: showingPaste ? "chevron.up" : "chevron.down")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(t.inkSoft)
                                }
                            }
                            .buttonStyle(.plain)

                            if showingPaste {
                                TextEditor(text: $pasted)
                                    .font(.system(size: 13, design: .monospaced))
                                    .scrollContentBackground(.hidden)
                                    .frame(height: 110)
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(t.surfaceSunken)
                                    )

                                Button(text.importCards) { importPasted() }
                                    .buttonStyle(ChunkyButtonStyle(
                                        fill: t.accent, edge: t.accentEdge, ink: t.ink,
                                        compact: true))
                                    .disabled(pasted.trimmingCharacters(in: .whitespaces).isEmpty)
                            }
                        }
                    }
                }
                .padding(.horizontal, Metrics.pad)
                .padding(.bottom, 24)
            }
        }
    }

    private func addCard() {
        let trimmedFront = front.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBack = back.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedFront.isEmpty, !trimmedBack.isEmpty else { return }
        withAnimation(Motion.card) {
            draft.cards.append(StudyCard(front: trimmedFront, back: trimmedBack))
        }
        front = ""
        back = ""
    }

    /// One card per line, front and back separated by a tab — the same shape as
    /// anki/German.txt, so cards move in and out of Anki without conversion.
    private func importPasted() {
        var added: [StudyCard] = []
        for line in pasted.split(whereSeparator: \.isNewline) {
            let parts = line.split(separator: "\t", maxSplits: 1, omittingEmptySubsequences: false)
            guard parts.count == 2 else { continue }
            let cardFront = parts[0].trimmingCharacters(in: .whitespaces)
            let cardBack = parts[1].trimmingCharacters(in: .whitespaces)
            guard !cardFront.isEmpty, !cardBack.isEmpty else { continue }
            added.append(StudyCard(front: cardFront, back: cardBack))
        }
        withAnimation(Motion.card) {
            draft.cards.append(contentsOf: added)
        }
        pasted = ""
        showingPaste = false
    }

    private func save() {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            nameMissing = true
            return
        }
        draft.name = name
        draft.subtitle = ""
        store.save(draft)
        onSave(draft)
    }
}

struct PlainField: View {
    var placeholder: String
    @Binding var text: String
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)
        Group {
            if RenderMode.isRendering {
                HStack {
                    Text(text.isEmpty ? placeholder : text)
                        .foregroundStyle(text.isEmpty ? t.inkSoft : t.ink)
                    Spacer()
                }
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundStyle(t.ink)
            }
        }
        .font(Typography.body)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(t.surfaceSunken)
        )
    }
}
