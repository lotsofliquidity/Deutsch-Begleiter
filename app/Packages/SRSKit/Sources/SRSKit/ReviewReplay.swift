import Foundation

/// One row in the review log. The log is the source of truth for a card's
/// schedule; state is replayed from it rather than stored twice.
public struct ReviewRecord: Equatable, Sendable {
    public var cardID: String
    public var deckID: String
    public var rating: Rating
    public var reviewedAt: Date

    public init(cardID: String, deckID: String, rating: Rating, reviewedAt: Date) {
        self.cardID = cardID
        self.deckID = deckID
        self.rating = rating
        self.reviewedAt = reviewedAt
    }
}

public enum ReviewReplay {
    /// Folds a card's history into its current state. Records are sorted by
    /// time first, so an out-of-order import cannot corrupt the schedule.
    public static func state(
        for reviews: [ReviewRecord],
        using scheduler: some Scheduler
    ) -> CardState {
        reviews
            .sorted { $0.reviewedAt < $1.reviewedAt }
            .reduce(CardState.new) { state, review in
                scheduler.next(state, rating: review.rating, at: review.reviewedAt)
            }
    }

    /// Groups a review log by card and replays each card separately.
    public static func states(
        for reviews: [ReviewRecord],
        using scheduler: some Scheduler
    ) -> [String: CardState] {
        Dictionary(grouping: reviews, by: \.cardID)
            .mapValues { state(for: $0, using: scheduler) }
    }
}
