import AVFoundation
import Foundation
import Speech

/// German speech recognition on the microphone. Prefers on-device recognition
/// when the language model is installed, so a session works offline.
@MainActor
final class GermanListener: ObservableObject {
    @Published private(set) var transcript = ""
    @Published private(set) var isListening = false
    @Published private(set) var level: Double = 0
    @Published private(set) var failure: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var lastLevelUpdate = Date.distantPast

    var isAvailable: Bool { recognizer?.isAvailable ?? false }

    /// Microphone and speech recognition are two separate permissions.
    func requestAccess() async -> Bool {
        let speech = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
        guard speech else {
            failure = "Speech recognition is not allowed."
            return false
        }

        #if os(iOS)
        let microphone = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
        #else
        let microphone = await AVCaptureDevice.requestAccess(for: .audio)
        #endif
        if !microphone {
            failure = "Microphone access is not allowed."
        }
        return microphone
    }

    func start() {
        guard !isListening else { return }
        guard let recognizer, recognizer.isAvailable else {
            failure = "German recognition is unavailable right now."
            return
        }

        transcript = ""
        failure = nil

        do {
            #if os(iOS)
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            #endif

            let request = SFSpeechAudioBufferRecognitionRequest()
            request.shouldReportPartialResults = true
            if recognizer.supportsOnDeviceRecognition {
                request.requiresOnDeviceRecognition = true
            }
            self.request = request

            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.removeTap(onBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
                request.append(buffer)
                self?.publishLevel(from: buffer)
            }

            engine.prepare()
            try engine.start()
            isListening = true

            task = recognizer.recognitionTask(with: request) { [weak self] result, error in
                guard let self else { return }
                Task { @MainActor in
                    if let result {
                        self.transcript = result.bestTranscription.formattedString
                    }
                    if error != nil || (result?.isFinal ?? false) {
                        self.stop()
                    }
                }
            }
        } catch {
            failure = error.localizedDescription
            stop()
        }
    }

    func stop() {
        guard isListening || engine.isRunning else { return }
        engine.stop()
        engine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil
        isListening = false
        level = 0
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    /// Rough RMS so the orb can breathe with the voice.
    private nonisolated func publishLevel(from buffer: AVAudioPCMBuffer) {
        guard let channel = buffer.floatChannelData?[0] else { return }
        let count = Int(buffer.frameLength)
        guard count > 0 else { return }

        var sum: Float = 0
        for index in 0..<count {
            sum += channel[index] * channel[index]
        }
        let rms = sqrt(sum / Float(count))
        let normalised = min(1, max(0, Double(rms) * 18))

        Task { @MainActor [weak self] in
            guard let self else { return }
            let now = Date()
            guard now.timeIntervalSince(self.lastLevelUpdate) > 0.06 else { return }
            self.lastLevelUpdate = now
            self.level = normalised
        }
    }
}
