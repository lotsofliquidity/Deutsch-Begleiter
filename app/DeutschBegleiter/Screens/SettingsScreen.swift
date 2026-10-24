import SwiftUI
import DesignKit
import SRSKit

struct SettingsScreen: View {
    @AppStorage("uiLanguage") private var language: UILanguage = .en
    @EnvironmentObject private var store: DeckStore
    @EnvironmentObject private var reviewStore: ReviewStore
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme

    @State private var apiKey = Keychain.load() ?? ""
    @State private var keyStatus = ""
    @State private var packSource = "https://github.com/lotsofliquidity/Deutsch-Begleiter/releases/latest"

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        ScreenScroll {
            VStack(alignment: .leading, spacing: 16) {
                Text(text.tabSettings)
                    .font(Typography.display(30))
                    .foregroundStyle(t.ink)

                languageCard(t)

                FloatCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(text.apiKey).font(Typography.headline).foregroundStyle(t.ink)
                        Text(text.apiKeyDetail)
                            .font(Typography.caption).foregroundStyle(t.inkSoft)
                        SecretField("sk-…", text: $apiKey)
                            .onChange(of: apiKey) { _, value in
                                Keychain.save(value)
                                keyStatus = ""
                            }
                        HStack(spacing: 8) {
                            Button(text.test) {
                                keyStatus = "…"
                                Task {
                                    keyStatus = await DeepSeekClient.test(apiKey)
                                }
                            }
                            .buttonStyle(ChunkyButtonStyle(
                                fill: t.surface, edge: t.sand, ink: t.ink, compact: true))
                            Chip("deepseek-flash", tint: Color(hex: 0xBFE0FF))
                        }
                        if !keyStatus.isEmpty {
                            Text(keyStatus)
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(keyStatus.contains("works") ? t.success : t.inkSoft)
                        }
                    }
                }

                packCard(t)
                reviewLogCard(t)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)
        }
    }

    private func languageCard(_ t: SceneTokens) -> some View {
        FloatCard {
            VStack(alignment: .leading, spacing: 10) {
                Text(text.appLanguage).font(Typography.headline).foregroundStyle(t.ink)
                HStack(spacing: 6) {
                    ForEach(UILanguage.allCases) { candidate in
                        let isOn = candidate == language
                        Button {
                            withAnimation(Motion.press) { language = candidate }
                        } label: {
                            Text(candidate.label)
                                .font(Typography.body)
                                .foregroundStyle(isOn ? t.ink : t.ink.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background {
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(isOn ? t.accent.opacity(0.92) : t.surfaceSunken)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func reviewLogCard(_ t: SceneTokens) -> some View {
        FloatCard {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(text.reviewLog).font(Typography.headline).foregroundStyle(t.ink)
                    Spacer()
                    Chip("\(reviewStore.reviewedToday()) / \(reviewStore.states.count)",
                         tint: Color(hex: 0xD9F0C4))
                }
                Text(text.localDatabase)
                    .font(Typography.caption)
                    .foregroundStyle(t.inkSoft)
                Text("reviewed today / cards scheduled · SM-2")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(t.inkSoft.opacity(0.85))
            }
        }
    }

    private func packCard(_ t: SceneTokens) -> some View {
        FloatCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(text.packs).font(Typography.headline).foregroundStyle(t.ink)
                    Spacer()
                    Chip("2026-10-24", tint: Color(hex: 0xCDEBA0))
                }

                ForEach(Level.allCases) { level in
                    let decks = store.decks(in: level)
                    let total = decks.reduce(0) { $0 + $1.totalCount }

                    HStack(spacing: 10) {
                        Text(level.rawValue)
                            .font(.system(size: 12, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 34, height: 26)
                            .background(Capsule().fill(
                                total > 0 ? Color(hex: 0x57AE6E) : t.inkSoft.opacity(0.35)))

                        Text(total > 0 ? "\(total.formatted()) \(text.cardsCount)" : "—")
                            .font(Typography.body)
                            .foregroundStyle(total > 0 ? t.ink : t.inkSoft)

                        Spacer()

                        Chip(total > 0 ? text.installed : text.notInstalled,
                             tint: total > 0 ? Color(hex: 0xD9F0C4) : t.surfaceSunken)
                    }
                }

                Text(text.unlevelled)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(t.inkSoft)

                Divider().opacity(0.4)

                Text(text.updateURL)
                    .font(Typography.caption)
                    .foregroundStyle(t.inkSoft)
                PlainField(placeholder: "https://…", text: $packSource)

                Button(text.update) {}
                    .buttonStyle(ChunkyButtonStyle(
                        fill: t.accent, edge: t.accentEdge, ink: t.ink, compact: true))
            }
        }
    }
}
