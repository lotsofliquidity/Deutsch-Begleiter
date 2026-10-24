import SwiftUI
import DesignKit

/// Debug-only launch arguments, used to screenshot a specific screen:
///   --tab course        --course g1        --cards a1-chunks
enum LaunchArgument {
    static var tab: Tab? {
        value(after: "--tab").flatMap(Tab.init(rawValue:))
    }

    static func value(after flag: String) -> String? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: flag), index + 1 < args.count else { return nil }
        return args[index + 1]
    }
}

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

    init(tab: Tab = LaunchArgument.tab ?? .home) {
        _tab = State(initialValue: tab)
    }

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        ZStack(alignment: .bottom) {
            if tab == .speak {
                t.skyTop.opacity(0.10)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            // Room for the floating tab bar. An explicit inset rather than
            // `safeAreaInset`, which did not reach the scroll views here: the
            // bar stayed on top of live content.
            .padding(.bottom, Metrics.tabBarClearance)
            .transition(.opacity.combined(with: .scale(scale: 0.98)))

            TabBar(selection: $tab)
                .frame(maxWidth: 620)
                .padding(.horizontal, 14)
                .padding(.bottom, 6)
        }
        // The scene bleeds behind everything, but as a *background* it no longer
        // stretches the layout into the safe area — which is what pushed content
        // under the tab bar and past the home indicator.
        .background {
            MeadowScene(horizon: tab == .speak ? 0.70 : 0.58)
                .blur(radius: tab == .speak ? 16 : 0)
                .animation(Motion.card, value: tab)
                .ignoresSafeArea()
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
