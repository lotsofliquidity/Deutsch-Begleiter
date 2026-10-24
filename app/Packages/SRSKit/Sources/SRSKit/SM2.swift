import Foundation

/// What the learner says about a card. Three buttons in the app, four grades
/// underneath — `hard` exists for the scheduler and for a future four-button row.
public enum Rating: Int, CaseIterable, Sendable {
    case again = 1
    case hard = 2
    case good = 3
    case easy = 4

    /// SM-2 quality, 0–5.
    var quality: Int {
        switch self {
        case .again: 2
        case .hard: 3
        case .good: 4
        case .easy: 5
        }
    }
}

public struct CardState: Equatable, Sendable {
    public var repetitions: Int
    public var intervalDays: Int
    public var easeFactor: Double
    public var due: Date
    public var lastReviewed: Date?
    public var lapses: Int

    public init(
        repetitions: Int = 0,
        intervalDays: Int = 0,
        easeFactor: Double = 2.5,
        due: Date = .distantPast,
        lastReviewed: Date? = nil,
        lapses: Int = 0
    ) {
        self.repetitions = repetitions
        self.intervalDays = intervalDays
        self.easeFactor = easeFactor
        self.due = due
        self.lastReviewed = lastReviewed
        self.lapses = lapses
    }

    /// A card that has never been reviewed.
    public static let new = CardState()

    public var isNew: Bool { lastReviewed == nil }
}

public protocol Scheduler: Sendable {
    func next(_ state: CardState, rating: Rating, at now: Date) -> CardState
}

/// Anki's classic algorithm. Kept deliberately simple and exactly checkable;
/// FSRS can replace it behind `Scheduler` once its output can be validated
/// against reference vectors.
public struct SM2: Scheduler {
    public var startEase: Double
    public var minEase: Double
    public var relearnMinutes: Int
    public var calendar: Calendar

    public init(
        startEase: Double = 2.5,
        minEase: Double = 1.3,
        relearnMinutes: Int = 10,
        calendar: Calendar = .current
    ) {
        self.startEase = startEase
        self.minEase = minEase
        self.relearnMinutes = relearnMinutes
        self.calendar = calendar
    }

    public func next(_ state: CardState, rating: Rating, at now: Date) -> CardState {
        let q = rating.quality
        let delta = 0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02)
        let ease = max(minEase, state.easeFactor + delta)

        guard q >= 3 else {
            return CardState(
                repetitions: 0,
                intervalDays: 0,
                easeFactor: ease,
                due: now.addingTimeInterval(Double(relearnMinutes) * 60),
                lastReviewed: now,
                lapses: state.lapses + 1
            )
        }

        let repetitions = state.repetitions + 1
        let intervalDays: Int
        switch repetitions {
        case 1: intervalDays = 1
        case 2: intervalDays = 6
        default: intervalDays = max(1, Int((Double(max(state.intervalDays, 1)) * ease).rounded()))
        }

        let due = calendar.date(byAdding: .day, value: intervalDays, to: now) ?? now
        return CardState(
            repetitions: repetitions,
            intervalDays: intervalDays,
            easeFactor: ease,
            due: due,
            lastReviewed: now,
            lapses: state.lapses
        )
    }
}
