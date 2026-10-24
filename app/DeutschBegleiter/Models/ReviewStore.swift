import Foundation
import GRDB
import SRSKit

/// One row in the review log. The log is the source of truth — a card's
/// schedule is replayed from its history rather than stored a second time.
struct ReviewRow: Codable, FetchableRecord, MutablePersistableRecord {
    static let databaseTableName = "review"

    var id: Int64?
    var cardID: String
    var deckID: String
    var rating: Int
    var reviewedAt: Date
}

enum ReviewDatabase {
    static func open(at url: URL) throws -> DatabaseQueue {
        let queue = try DatabaseQueue(path: url.path)
        try migrate(queue)
        return queue
    }

    static func inMemory() throws -> DatabaseQueue {
        let queue = try DatabaseQueue()
        try migrate(queue)
        return queue
    }

    static func defaultURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("DeutschBegleiter", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("reviews.sqlite")
    }

    private static func migrate(_ queue: DatabaseQueue) throws {
        var migrator = DatabaseMigrator()
        migrator.registerMigration("v1") { db in
            try db.create(table: "review") { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("cardID", .text).notNull()
                table.column("deckID", .text).notNull()
                table.column("rating", .integer).notNull()
                table.column("reviewedAt", .datetime).notNull()
            }
            try db.create(
                index: "review_cardID",
                on: "review",
                columns: ["cardID", "reviewedAt"]
            )
        }
        try migrator.migrate(queue)
    }
}

/// Holds the schedule for every card: replayed from the log at launch, updated
/// on each rating.
final class ReviewStore: ObservableObject {
    @Published private(set) var states: [String: CardState] = [:]

    /// New cards introduced per session — without a cap the first launch would
    /// open a 595-card queue.
    var newPerSession = 20

    private let dbQueue: DatabaseQueue
    private let scheduler = SM2()

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
        reload()
    }

    convenience init() {
        let queue = (try? ReviewDatabase.open(at: ReviewDatabase.defaultURL()))
            ?? (try? ReviewDatabase.inMemory())
            ?? (try! DatabaseQueue())
        self.init(dbQueue: queue)
    }

    static func inMemory() -> ReviewStore {
        ReviewStore(dbQueue: (try? ReviewDatabase.inMemory()) ?? (try! DatabaseQueue()))
    }

    private func reload() {
        let rows = (try? dbQueue.read { db in
            try ReviewRow.fetchAll(db)
        }) ?? []

        let records = rows.compactMap { row -> ReviewRecord? in
            guard let rating = Rating(rawValue: row.rating) else { return nil }
            return ReviewRecord(
                cardID: row.cardID,
                deckID: row.deckID,
                rating: rating,
                reviewedAt: row.reviewedAt
            )
        }

        states = ReviewReplay.states(for: records, using: scheduler)
    }

    func state(for cardID: String) -> CardState {
        states[cardID] ?? .new
    }

    /// Records a rating and returns the card's new schedule.
    ///
    /// The timestamp is truncated to milliseconds first: SQLite keeps dates at
    /// that resolution, so a schedule computed from an untruncated `Date` would
    /// differ from the same schedule replayed after a relaunch.
    @discardableResult
    func record(card: StudyCard, deckID: String, rating: Rating, at now: Date = .now) -> CardState {
        let timestamp = Date(
            timeIntervalSince1970: (now.timeIntervalSince1970 * 1000).rounded() / 1000
        )
        var row = ReviewRow(
            id: nil,
            cardID: card.id,
            deckID: deckID,
            rating: rating.rawValue,
            reviewedAt: timestamp
        )
        try? dbQueue.write { db in
            try row.insert(db)
        }

        let next = scheduler.next(state(for: card.id), rating: rating, at: timestamp)
        states[card.id] = next
        return next
    }

    /// Cards to study now: everything due, then new cards up to the session cap.
    func queue(for deck: Deck, at now: Date = .now) -> [StudyCard] {
        let due = deck.cards.filter { card in
            let state = state(for: card.id)
            return !state.isNew && state.due <= now
        }
        let fresh = deck.cards.filter { state(for: $0.id).isNew }.prefix(newPerSession)

        return due + fresh
    }

    func dueCount(for decks: [Deck], at now: Date = .now) -> Int {
        decks.reduce(0) { total, deck in
            total + deck.cards.filter { card in
                let state = state(for: card.id)
                return !state.isNew && state.due <= now
            }.count
        }
    }

    func reviewedToday(at now: Date = .now) -> Int {
        let start = Calendar.current.startOfDay(for: now)
        return (try? dbQueue.read { db in
            try ReviewRow.filter(Column("reviewedAt") >= start).fetchCount(db)
        }) ?? 0
    }
}
