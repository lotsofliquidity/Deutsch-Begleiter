import XCTest
@testable import SRSKit

final class SM2Tests: XCTestCase {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    private var scheduler: SM2 {
        SM2(calendar: calendar)
    }

    private let start = Date(timeIntervalSince1970: 1_800_000_000)

    private func days(_ state: CardState) -> Int {
        calendar.dateComponents([.day], from: start, to: state.due).day ?? -1
    }

    func testFirstGoodSchedulesOneDay() {
        let state = scheduler.next(.new, rating: .good, at: start)
        XCTAssertEqual(state.repetitions, 1)
        XCTAssertEqual(state.intervalDays, 1)
        XCTAssertEqual(days(state), 1)
        XCTAssertEqual(state.easeFactor, 2.5, accuracy: 0.0001)
        XCTAssertFalse(state.isNew)
    }

    func testSecondGoodSchedulesSixDays() {
        let first = scheduler.next(.new, rating: .good, at: start)
        let second = scheduler.next(first, rating: .good, at: first.due)
        XCTAssertEqual(second.repetitions, 2)
        XCTAssertEqual(second.intervalDays, 6)
    }

    func testThirdGoodMultipliesByEase() {
        var state = scheduler.next(.new, rating: .good, at: start)
        state = scheduler.next(state, rating: .good, at: state.due)
        let third = scheduler.next(state, rating: .good, at: state.due)
        // 6 * 2.5 — ease does not move on a plain "good"
        XCTAssertEqual(third.intervalDays, 15)
        XCTAssertEqual(third.easeFactor, 2.5, accuracy: 0.0001)
    }

    func testEasyRaisesEase() {
        let state = scheduler.next(.new, rating: .easy, at: start)
        XCTAssertEqual(state.easeFactor, 2.6, accuracy: 0.0001)
    }

    func testHardLowersEase() {
        let state = scheduler.next(.new, rating: .hard, at: start)
        XCTAssertEqual(state.easeFactor, 2.36, accuracy: 0.0001)
    }

    func testAgainResetsToRelearn() {
        var state = scheduler.next(.new, rating: .good, at: start)
        state = scheduler.next(state, rating: .good, at: state.due)

        let lapsed = scheduler.next(state, rating: .again, at: state.due)
        XCTAssertEqual(lapsed.repetitions, 0)
        XCTAssertEqual(lapsed.lapses, 1)
        XCTAssertEqual(lapsed.easeFactor, 2.18, accuracy: 0.0001)
        XCTAssertEqual(
            lapsed.due.timeIntervalSince(state.due),
            600,
            accuracy: 1,
            "a lapse returns in ten minutes, not a day"
        )
    }

    func testEaseNeverFallsBelowFloor() {
        var state = CardState.new
        for _ in 0..<20 {
            state = scheduler.next(state, rating: .again, at: start)
        }
        XCTAssertEqual(state.easeFactor, 1.3, accuracy: 0.0001)
    }

    func testRecoveryAfterLapseStartsAtOneDay() {
        let lapsed = scheduler.next(.new, rating: .again, at: start)
        let recovered = scheduler.next(lapsed, rating: .good, at: lapsed.due)
        XCTAssertEqual(recovered.repetitions, 1)
        XCTAssertEqual(recovered.intervalDays, 1)
    }

    func testReplayMatchesStepwiseApplication() {
        let reviews = [
            ReviewRecord(cardID: "c1", deckID: "a1", rating: .good, reviewedAt: start),
            ReviewRecord(cardID: "c1", deckID: "a1", rating: .easy, reviewedAt: start + 86_400),
            ReviewRecord(cardID: "c1", deckID: "a1", rating: .good, reviewedAt: start + 86_400 * 8)
        ]

        let stepwise = reviews.reduce(CardState.new) { state, review in
            scheduler.next(state, rating: review.rating, at: review.reviewedAt)
        }

        XCTAssertEqual(ReviewReplay.state(for: reviews, using: scheduler), stepwise)
    }

    func testReplaySortsOutOfOrderHistory() {
        let ordered = [
            ReviewRecord(cardID: "c1", deckID: "a1", rating: .good, reviewedAt: start),
            ReviewRecord(cardID: "c1", deckID: "a1", rating: .good, reviewedAt: start + 86_400)
        ]
        let shuffled = [ordered[1], ordered[0]]
        XCTAssertEqual(
            ReviewReplay.state(for: ordered, using: scheduler),
            ReviewReplay.state(for: shuffled, using: scheduler)
        )
    }

    func testStatesGroupsByCard() {
        let reviews = [
            ReviewRecord(cardID: "c1", deckID: "a1", rating: .good, reviewedAt: start),
            ReviewRecord(cardID: "c2", deckID: "a1", rating: .again, reviewedAt: start)
        ]
        let states = ReviewReplay.states(for: reviews, using: scheduler)
        XCTAssertEqual(Set(states.keys), ["c1", "c2"])
        XCTAssertEqual(states["c1"]?.repetitions, 1)
        XCTAssertEqual(states["c2"]?.lapses, 1)
    }
}
