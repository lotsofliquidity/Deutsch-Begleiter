import Foundation
import Combine

enum Level: String, CaseIterable, Identifiable, Sendable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"

    var id: String { rawValue }
}

/// Who is allowed to change a deck. `generated` is reserved for a later
/// "built from what you keep getting wrong" deck; nothing produces it yet.
enum DeckOrigin: String, Sendable {
    case predefined
    case custom
    case generated
}

struct StudyCard: Identifiable, Hashable, Sendable {
    /// Stable across launches and pack refreshes — review history hangs off it.
    var id: String
    var front: String
    var back: String

    init(id: String = UUID().uuidString, front: String, back: String) {
        self.id = id
        self.front = front
        self.back = back
    }
}

struct Deck: Identifiable, Sendable {
    var id = UUID()
    var name: String
    var level: Level
    var origin: DeckOrigin
    var subtitle: String
    /// Cards in the published pack, which may exceed what is loaded locally.
    var catalogueCount: Int
    var cards: [StudyCard]

    var isEditable: Bool { origin == .custom }

    var totalCount: Int { origin == .custom ? cards.count : catalogueCount }

    /// A predefined deck carrying only a sample of its pack.
    var isPartial: Bool { origin == .predefined && cards.count < catalogueCount }
}

final class DeckStore: ObservableObject {
    @Published private(set) var decks: [Deck]

    init(decks: [Deck] = DeckPack.load()) {
        self.decks = decks
    }

    func deck(_ id: Deck.ID) -> Deck? {
        decks.first { $0.id == id }
    }

    func decks(in level: Level) -> [Deck] {
        decks.filter { $0.level == level }
    }

    func hasDeck(in level: Level) -> Bool {
        decks.contains { $0.level == level }
    }

    @discardableResult
    func save(_ deck: Deck) -> Deck {
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index] = deck
        } else {
            decks.append(deck)
        }
        return deck
    }

    func update(_ deck: Deck) {
        guard let index = decks.firstIndex(where: { $0.id == deck.id }) else { return }
        decks[index] = deck
    }

    func delete(_ id: Deck.ID) {
        decks.removeAll { $0.id == id }
    }
}

struct CardPackFile: Decodable {
    struct Pack: Decodable {
        let id: String
        let name: String
        let level: String
        let subtitle: String
        let cards: [PackCard]
    }

    struct PackCard: Decodable {
        let id: String
        let front: String
        let back: String
    }

    let source: String
    let generated: String
    let decks: [Pack]
}

/// The bundled card pack, generated from anki/Brainscape-German.txt by
/// tools/export_brainscape.py. Missing file means the pack was never exported —
/// the library then shows an empty shelf rather than inventing cards.
enum DeckPack {
    static func load(bundle: Bundle = .main) -> [Deck] {
        guard
            let url = bundle.url(forResource: "decks", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let file = try? JSONDecoder().decode(CardPackFile.self, from: data)
        else {
            return []
        }

        return file.decks.compactMap { pack in
            guard let level = Level(rawValue: pack.level) else { return nil }
            return Deck(
                name: pack.name,
                level: level,
                origin: .predefined,
                subtitle: pack.subtitle,
                catalogueCount: pack.cards.count,
                cards: pack.cards.map {
                    StudyCard(id: $0.id, front: $0.front, back: $0.back)
                }
            )
        }
    }
}
