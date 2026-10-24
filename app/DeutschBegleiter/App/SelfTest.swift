import AVFoundation
import Foundation
import SRSKit

#if os(macOS)
/// End-to-end check of the review log: write ratings through the store, throw
/// the store away, reopen the same file, and compare the replayed schedule.
/// Run with `--selftest`.
@MainActor
enum SelfTest {
    static func runIfRequested() -> Bool {
        if CommandLine.arguments.contains("--selftest-voice") {
            for level in Conversation.Level.allCases {
                let words = level.guidance.split(separator: " ").prefix(9).joined(separator: " ")
                print("level \(level.rawValue): rate \(level.speechRate) · \"\(words)…\"")
            }
            let voices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("de") }
            print("German voices installed: \(voices.count)")
            for voice in voices.prefix(6) {
                print("  \(voice.name) · \(voice.language) · \(voice.quality == .premium ? "premium" : voice.quality == .enhanced ? "enhanced" : "default")")
            }
            print("chosen: \(GermanSpeaker.germanVoice()?.name ?? "none")")

            Keychain.save("selftest-key-123")
            let loaded = Keychain.load()
            Keychain.delete()
            print("keychain round-trip: \(loaded == "selftest-key-123" ? "OK" : "FAILED") · cleared: \(Keychain.load() == nil)")
            return true
        }

        guard CommandLine.arguments.contains("--selftest") else { return false }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("srs-selftest-\(UUID().uuidString).sqlite")
        defer { try? FileManager.default.removeItem(at: url) }

        do {
            let first = ReviewStore(dbQueue: try ReviewDatabase.open(at: url))
            let card = StudyCard(id: "a1-selftest", front: "front", back: "back")
            let start = Date()

            let good = first.record(card: card, deckID: "a1", rating: .good, at: start)
            print("good  → interval \(good.intervalDays)d  ease \(fmt(good.easeFactor))")

            let again = first.record(card: card, deckID: "a1", rating: .again, at: good.due)
            print("again → lapses \(again.lapses)  due +\(Int(again.due.timeIntervalSince(good.due) / 60))m")

            // a second store reopens the same file: this is the persistence claim
            let second = ReviewStore(dbQueue: try ReviewDatabase.open(at: url))
            let restored = second.state(for: card.id)
            print("reopened → lapses \(restored.lapses)  ease \(fmt(restored.easeFactor))  reps \(restored.repetitions)")

            if matches(restored, again) {
                print("SELFTEST OK")
            } else {
                print("SELFTEST MISMATCH")
                print("  in memory: \(again)")
                print("  replayed : \(restored)")
                exit(1)
            }
        } catch {
            print("SELFTEST FAILED: \(error)")
            exit(1)
        }
        return true
    }

    /// SQLite keeps dates as text at millisecond resolution, so a replayed
    /// `due` lands within a fraction of a millisecond of the in-memory one.
    /// The schedule is day-granular, so a second of slack is honest; everything
    /// that decides the interval must match exactly.
    private static func matches(_ a: CardState, _ b: CardState) -> Bool {
        a.repetitions == b.repetitions
            && a.intervalDays == b.intervalDays
            && a.lapses == b.lapses
            && abs(a.easeFactor - b.easeFactor) < 1e-9
            && abs(a.due.timeIntervalSince(b.due)) < 1
    }

    private static func fmt(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}
#endif
