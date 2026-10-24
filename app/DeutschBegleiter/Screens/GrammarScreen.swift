import SwiftUI
import DesignKit

struct GrammarScreen: View {
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme

    /// Section names stay German — they name German grammar topics, which is
    /// material the learner needs to recognise, not chrome.
    private let sections = [
        "Artikel", "Die vier Fälle", "Pronomen", "Nomen", "Präpositionen",
        "Verben — Präsens", "Modalverben", "Imperativ", "Vergangenheit",
        "Adjektive", "Satzbau", "Negation", "Zeit & Zahlen", "Register", "Chunks"
    ]

    private let columns = [GridItem(.adaptive(minimum: 140), spacing: 10)]

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        ScreenScroll {
            VStack(alignment: .leading, spacing: 16) {
                Text(text.tabGrammar)
                    .font(Typography.display(30))
                    .foregroundStyle(t.ink)
                Text(text.grammarSubtitle)
                    .font(Typography.caption)
                    .foregroundStyle(t.ink.opacity(0.6))

                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(sections, id: \.self) { name in
                        Text(name)
                            .font(Typography.body)
                            .foregroundStyle(t.ink)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(t.surface.opacity(0.94))
                            )
                    }
                }

                FloatCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Artikel im Nominativ")
                            .font(Typography.headline)
                            .foregroundStyle(t.ink)

                        VStack(spacing: 6) {
                            GenderRow(label: "der", word: "Tisch", color: NounColor.der)
                            GenderRow(label: "die", word: "Lampe", color: NounColor.die)
                            GenderRow(label: "das", word: "Buch", color: NounColor.das)
                            GenderRow(label: "die", word: "Stühle", color: NounColor.plural,
                                      note: text.plural)
                        }
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)
        }
    }
}

private struct GenderRow: View {
    var label: String
    var word: String
    var color: Color
    var note: String? = nil
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)
        HStack(spacing: 10) {
            Text(label)
                .font(Typography.headline)
                .foregroundStyle(.white)
                .frame(width: 56)
                .padding(.vertical, 6)
                .background(Capsule().fill(color))

            Text(word).font(Typography.body).foregroundStyle(t.ink)
            if let note {
                Text(note).font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(t.inkSoft)
            }
            Spacer()
        }
    }
}
