import SwiftUI
import DesignKit

enum Tab: String, CaseIterable, Identifiable {
    case home, speak, course, cards, settings

    var id: String { rawValue }

    func title(_ text: UIText) -> String {
        switch self {
        case .home: text.tabHome
        case .speak: text.tabSpeak
        case .course: text.tabCourse
        case .cards: text.tabCards
        case .settings: text.tabSettings
        }
    }

    var symbol: String {
        switch self {
        case .home: "house.fill"
        case .speak: "waveform"
        case .course: "book.closed.fill"
        case .cards: "rectangle.on.rectangle.angled"
        case .settings: "gearshape.fill"
        }
    }
}

struct RootView: View {
    @StateObject private var store = DeckStore()
    @StateObject private var reviews = RenderMode.isRendering ? ReviewStore.inMemory() : ReviewStore()
    @State private var pack = CoursePack.load()
    @AppStorage("uiLanguage") private var language: UILanguage = .en
    @State private var tab: Tab
    @Environment(\.colorScheme) private var scheme

    init(tab: Tab = .home) {
        _tab = State(initialValue: tab)
    }

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        ZStack {
            MeadowScene(horizon: tab == .speak ? 0.70 : 0.58)
                .blur(radius: tab == .speak ? 16 : 0)
                .animation(Motion.card, value: tab)

            if tab == .speak {
                t.skyTop.opacity(0.10).ignoresSafeArea()
            }

            Group {
                switch tab {
                case .home: HomeScreen()
                case .speak: SpeakScreen()
                case .course: CourseTab()
                case .cards: CardsTab()
                case .settings: SettingsScreen()
                }
            }
            .frame(maxWidth: 620)
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            TabBar(selection: $tab)
                .frame(maxWidth: 620)
                .padding(.horizontal, 14)
                .padding(.bottom, 6)
        }
        .environmentObject(store)
        .environmentObject(reviews)
        .environment(\.coursePack, pack)
        .environment(\.uiText, UIText(language: language))
        .animation(Motion.card, value: tab)
    }
}

struct TabBar: View {
    @Binding var selection: Tab
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)
        HStack(spacing: 2) {
            ForEach(Tab.allCases) { tab in
                let isOn = tab == selection
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 17, weight: .bold))
                        Text(tab.title(text))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                    }
                    .foregroundStyle(isOn ? t.ink : t.ink.opacity(0.45))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background {
                        if isOn {
                            Capsule().fill(t.accent.opacity(0.9))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(t.surface.opacity(0.94))
                .shadow(color: t.leafDark.opacity(0.18), radius: 16, y: 6)
        )
        .animation(Motion.press, value: selection)
    }
}
