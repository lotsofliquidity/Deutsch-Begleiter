import SwiftUI
import DesignKit

/// Navigation for the Cards tab. A route enum rather than `NavigationStack`,
/// because a system nav bar would draw grey chrome through the meadow.
struct CardsTab: View {
    @EnvironmentObject private var store: DeckStore
    @State private var level: Level = .a1
    @State private var route: Route?

    enum Route: Hashable {
        case detail(Deck.ID)
        case study(Deck.ID)
        case edit(Deck.ID)
        case create
    }

    var body: some View {
        Group {
            switch route {
            case .none:
                DeckLibraryScreen(
                    level: $level,
                    onOpen: { route = .detail($0.id) },
                    onNew: { route = .create }
                )

            case .detail(let id):
                if let deck = store.deck(id) {
                    DeckDetailScreen(
                        deck: deck,
                        onBack: { route = nil },
                        onStudy: { route = .study(id) },
                        onEdit: { route = .edit(id) },
                        onDelete: {
                            store.delete(id)
                            route = nil
                        }
                    )
                } else {
                    EmptyView()
                }

            case .study(let id):
                if let deck = store.deck(id) {
                    StudyScreen(deck: deck, onExit: { route = .detail(id) })
                } else {
                    EmptyView()
                }

            case .edit(let id):
                if let deck = store.deck(id) {
                    DeckEditorScreen(
                        existing: deck,
                        onSave: { _ in route = .detail(id) },
                        onCancel: { route = .detail(id) }
                    )
                } else {
                    EmptyView()
                }

            case .create:
                DeckEditorScreen(
                    existing: nil,
                    onSave: { deck in route = .detail(deck.id) },
                    onCancel: { route = nil }
                )
            }
        }
        .animation(Motion.card, value: route)
    }
}

/// A back affordance that sits in the scene instead of a navigation bar.
struct BackChip: View {
    var label: String
    var action: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left").font(.system(size: 11, weight: .bold))
                Text(label).font(Typography.caption)
            }
            .foregroundStyle(t.ink)
            .padding(.horizontal, 11)
            .padding(.vertical, 7)
            .background(Capsule().fill(t.surface.opacity(0.92)))
        }
        .buttonStyle(.plain)
    }
}
