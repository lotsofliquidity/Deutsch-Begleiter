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

            // `@Sendable` is load-bearing: without it this closure is inferred
            // to be main-actor isolated (it is formed inside a @MainActor
            // method), and the tap really runs on the realtime audio thread —
            // which traps with _dispatch_assert_queue_fail.
            nonisolated(unsafe) let audioRequest = request
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { @Sendable [weak self] buffer, _ in
                audioRequest.append(buffer)
                self?.publishLevel(from: buffer)
            }

            engine.prepare()
            try engine.start()
            isListening = true

            // Same reason as the tap: this handler is delivered on a background
            // queue, so it must not inherit main-actor isolation. Only Sendable
            // values cross into the MainActor task.
            task = recognizer.recognitionTask(with: request) { @Sendable [weak self] result, error in
                let text = result?.bestTranscription.formattedString
                let finished = (result?.isFinal ?? false) || error != nil
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    if let text, !text.isEmpty { self.transcript = text }
                    if finished { self.stop() }
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

    #if DEBUG
    /// Breadcrumbs to a file, one per step, so a trap leaves evidence of which
    /// call it died in. Used by `--probe-audio`.
    nonisolated static func crumb(_ text: String) {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("probe.txt")
        let line = text + "\n"
        if let handle = try? FileHandle(forWritingTo: path) {
            handle.seekToEndOfFile()
            handle.write(Data(line.utf8))
            try? handle.close()
        } else {
            try? line.write(to: path, atomically: true, encoding: .utf8)
        }
    }

    /// Runs the real audio tap with no recogniser, purely to prove the callback
    /// executes off the main thread without tripping an actor assertion.
    func probeTap(seconds: Double = 3) async {
        final class Tally: @unchecked Sendable {
            var buffers = 0
            var peak: Float = 0
        }

        try? FileManager.default.removeItem(
            at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("probe.txt")
        )
        Self.crumb("0 entered")

        do {
            #if os(iOS)
            Self.crumb("1 session-category")
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            Self.crumb("2 session-activate")
            try session.setActive(true)
            Self.crumb("3 session-active")
            #endif

            Self.crumb("4 inputNode")
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            Self.crumb("5 format ch=\(format.channelCount) rate=\(format.sampleRate)")

            let tally = Tally()
            input.removeTap(onBus: 0)
            Self.crumb("6 removeTap")
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { @Sendable buffer, _ in
                tally.buffers += 1
                if let channel = buffer.floatChannelData?[0] {
                    tally.peak = max(tally.peak, abs(channel[0]))
                }
            }
            Self.crumb("7 installTap")

            engine.prepare()
            Self.crumb("8 prepare")
            try engine.start()
            Self.crumb("9 engine-started")

            try? await Task.sleep(for: .seconds(seconds))
            Self.crumb("10 slept buffers=\(tally.buffers) peak=\(tally.peak)")

            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
            Self.crumb("11 stopped")
        } catch {
            Self.crumb("! failed: \(error.localizedDescription)")
        }
    }
    #endif

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
