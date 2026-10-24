import AVFoundation
import Foundation
import Speech

/// German speech recognition on the microphone.
///
/// Deliberately **not** `@MainActor`. The audio tap and the recogniser callback
/// are invoked by the frameworks on their own threads; any actor isolation on
/// this type makes those callbacks trip
/// `_dispatch_assert_queue_fail: Block was expected to execute on queue [main]`.
/// Published state is mutated only from a `DispatchQueue.main.async` block, so
/// there is no isolation to violate in either callback.
final class GermanListener: ObservableObject, @unchecked Sendable {
    @Published private(set) var transcript = ""
    @Published private(set) var isListening = false
    @Published private(set) var level: Double = 0
    @Published private(set) var failure: String?

    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    private let engine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?

    /// Only touched on the main queue.
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
            publish { $0.failure = "Speech recognition is not allowed." }
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
            publish { $0.failure = "Microphone access is not allowed." }
        }
        return microphone
    }

    func start() {
        guard !isListening else { return }
        guard let recognizer, recognizer.isAvailable else {
            publish { $0.failure = "German recognition is unavailable right now." }
            return
        }

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

            // `@Sendable` keeps this closure free of any actor inference: it is
            // built on the main thread but runs on the real-time audio thread.
            nonisolated(unsafe) let audioRequest = request
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { @Sendable [weak self] buffer, _ in
                audioRequest.append(buffer)
                self?.publishLevel(from: buffer)
            }

            engine.prepare()
            try engine.start()

            publish {
                $0.isListening = true
                $0.transcript = ""
                $0.failure = nil
            }

            task = recognizer.recognitionTask(with: request) { @Sendable [weak self] result, error in
                let text = result?.bestTranscription.formattedString
                let finished = (result?.isFinal ?? false) || error != nil
                self?.publish {
                    if let text, !text.isEmpty { $0.transcript = text }
                }
                if finished { self?.stop() }
            }
        } catch {
            publish { $0.failure = error.localizedDescription }
            stop()
        }
    }

    func stop() {
        if engine.isRunning {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
        }
        request?.endAudio()
        task?.cancel()
        request = nil
        task = nil

        publish {
            $0.isListening = false
            $0.level = 0
        }

        #if os(iOS)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        #endif
    }

    // MARK: - main-queue state

    /// Every mutation of published state goes through here. A plain GCD block on
    /// the main queue has no actor check, unlike a task hop from an isolated
    /// context, which is what made this class trap before.
    private func publish(_ mutate: @escaping @Sendable (GermanListener) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            mutate(self)
        }
    }

    /// Rough RMS so the orb can breathe with the voice.
    private func publishLevel(from buffer: AVAudioPCMBuffer) {
        guard let channel = buffer.floatChannelData?[0] else { return }
        let count = Int(buffer.frameLength)
        guard count > 0 else { return }

        var sum: Float = 0
        for index in 0..<count {
            sum += channel[index] * channel[index]
        }
        let rms = sqrt(sum / Float(count))
        let normalised = min(1, max(0, Double(rms) * 18))

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let now = Date()
            guard now.timeIntervalSince(self.lastLevelUpdate) > 0.06 else { return }
            self.lastLevelUpdate = now
            self.level = normalised
        }
    }

    #if DEBUG
    /// Regression check for `--probe-audio`: runs the real tap, writes a
    /// breadcrumb per step so a trap leaves evidence of the exact call.
    func probeTap(seconds: Double = 3) async {
        final class Tally: @unchecked Sendable {
            var buffers = 0
            var peak: Float = 0
        }

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("probe.txt")
        try? FileManager.default.removeItem(at: path)

        func crumb(_ text: String) {
            let line = text + "\n"
            if let handle = try? FileHandle(forWritingTo: path) {
                handle.seekToEndOfFile()
                handle.write(Data(line.utf8))
                try? handle.close()
            } else {
                try? line.write(to: path, atomically: true, encoding: .utf8)
            }
        }

        crumb("0 entered")

        do {
            #if os(iOS)
            crumb("1 session-category")
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement, options: .duckOthers)
            crumb("2 session-activate")
            try session.setActive(true)
            crumb("3 session-active")
            #endif

            crumb("4 inputNode")
            let input = engine.inputNode
            let format = input.outputFormat(forBus: 0)
            crumb("5 format ch=\(format.channelCount) rate=\(format.sampleRate)")

            let tally = Tally()
            input.removeTap(onBus: 0)
            crumb("6 removeTap")
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { @Sendable [weak self] buffer, _ in
                tally.buffers += 1
                if let channel = buffer.floatChannelData?[0] {
                    tally.peak = max(tally.peak, abs(channel[0]))
                }
                self?.publishLevel(from: buffer)
            }
            crumb("7 installTap")

            engine.prepare()
            crumb("8 prepare")
            try engine.start()
            crumb("9 engine-started")

            try? await Task.sleep(for: .seconds(seconds))
            crumb("10 slept buffers=\(tally.buffers) peak=\(tally.peak)")

            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
            crumb("11 stopped")
        } catch {
            crumb("! failed: \(error.localizedDescription)")
        }
    }
    #endif
}
