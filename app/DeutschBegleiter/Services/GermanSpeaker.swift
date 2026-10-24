import AVFoundation
import Foundation

/// Speaks the tutor's German. Picks the best installed German voice and stays
/// out of the way of the microphone: the session is configured for playback
/// with ducking, so `voices` can be interrupted by starting to listen again.
@MainActor
final class GermanSpeaker: NSObject, ObservableObject {
    @Published private(set) var isSpeaking = false

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    static func germanVoice() -> AVSpeechSynthesisVoice? {
        let german = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.hasPrefix("de")
        }
        return german.first { $0.quality == .premium }
            ?? german.first { $0.quality == .enhanced }
            ?? AVSpeechSynthesisVoice(language: "de-DE")
            ?? german.first
    }

    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        stop()

        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: .duckOthers)
            try session.setActive(true)
        } catch {
            // speaking still works with the default session
        }
        #endif

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = Self.germanVoice()
        utterance.rate = 0.48
        utterance.pitchMultiplier = 1.0
        synthesizer.speak(utterance)
        isSpeaking = true
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
}

extension GermanSpeaker: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in self.isSpeaking = false }
    }

    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didCancel utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
