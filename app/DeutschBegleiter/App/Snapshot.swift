import SwiftUI
import DesignKit

#if os(macOS)
import AppKit

/// Renders the real screens offscreen so the design can be reviewed without
/// launching the app (and diffed later as a visual regression baseline).
@MainActor
enum Snapshot {
    static func runIfRequested() -> Bool {
        guard
            let flag = CommandLine.arguments.firstIndex(of: "--snapshot"),
            CommandLine.arguments.count > flag + 1
        else { return false }

        let directory = URL(fileURLWithPath: CommandLine.arguments[flag + 1])
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        RenderMode.isRendering = true

        // phone-sized portrait, and a desktop window
        let sizes: [(name: String, size: CGSize)] = [
            ("phone", CGSize(width: 440, height: 900)),
            ("desktop", CGSize(width: 1180, height: 780))
        ]

        for tab in Tab.allCases {
            for variant in sizes {
                render(
                    RootView(tab: tab)
                        .frame(width: variant.size.width, height: variant.size.height),
                    to: directory.appendingPathComponent("\(tab.rawValue)-\(variant.name).png")
                )
            }
        }

        // the empty B1 shelf is a state worth seeing, and it is unreachable
        // from a plain tab render
        render(
            ZStack {
                MeadowScene(horizon: 0.58)
                DeckLibraryScreen(level: .constant(.b1), onOpen: { _ in }, onNew: {})
            }
            .environmentObject(DeckStore())
            .frame(width: 440, height: 900),
            to: directory.appendingPathComponent("cards-b1-phone.png")
        )

        // proves the UI-language switch actually reaches the chrome
        UserDefaults.standard.set("de", forKey: "uiLanguage")
        render(
            RootView(tab: .home).frame(width: 440, height: 900),
            to: directory.appendingPathComponent("home-de-phone.png")
        )
        UserDefaults.standard.set("en", forKey: "uiLanguage")

        // the course reader is the only place tables are laid out
        let pack = CoursePack.load()
        if let rule = pack.grammar.first {
            render(
                ZStack {
                    MeadowScene(horizon: 0.58)
                    CourseReader(
                        title: rule.title,
                        subtitle: "§\(rule.number)",
                        blocks: rule.blocks,
                        onBack: {}
                    )
                }
                .environment(\.coursePack, pack)
                .frame(width: 440, height: 900),
                to: directory.appendingPathComponent("course-rule-phone.png")
            )
        }
        if let unit = pack.levels.first?.units.first {
            render(
                ZStack {
                    MeadowScene(horizon: 0.58)
                    CourseReader(title: unit.title, subtitle: nil, blocks: unit.blocks, onBack: {})
                }
                .environment(\.coursePack, pack)
                .frame(width: 440, height: 900),
                to: directory.appendingPathComponent("course-unit-phone.png")
            )
        }

        // the deck flow is three levels deep, so the tab render never reaches it
        let store = DeckStore()
        if let a1 = store.decks.first(where: { $0.level == .a1 }) {
            render(
                ZStack {
                    MeadowScene(horizon: 0.58)
                    DeckDetailScreen(deck: a1, onBack: {}, onStudy: {}, onEdit: {}, onDelete: {})
                }
                .environmentObject(store)
                .frame(width: 440, height: 900),
                to: directory.appendingPathComponent("deck-detail-phone.png")
            )
            render(
                ZStack {
                    MeadowScene(horizon: 0.58)
                    StudyScreen(deck: a1, onExit: {}, previewQueue: Array(a1.cards.prefix(20)))
                }
                .environmentObject(store)
                .frame(width: 440, height: 900),
                to: directory.appendingPathComponent("study-phone.png")
            )
            render(
                ZStack {
                    MeadowScene(horizon: 0.58)
                    StudyScreen(deck: a1, onExit: {}, initiallyRevealed: true,
                                previewQueue: Array(a1.cards.prefix(20)))
                }
                .environmentObject(store)
                .frame(width: 440, height: 900),
                to: directory.appendingPathComponent("study-revealed-phone.png")
            )
        }

        print("snapshots written to \(directory.path)")
        return true
    }

    private static func render(_ view: some View, to url: URL) {
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard
            let image = renderer.nsImage,
            let tiff = image.tiffRepresentation,
            let rep = NSBitmapImageRep(data: tiff),
            let png = rep.representation(using: .png, properties: [:])
        else {
            print("failed to render \(url.lastPathComponent)")
            return
        }
        try? png.write(to: url)
    }
}
#endif
