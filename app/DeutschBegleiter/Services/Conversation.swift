import Foundation

/// One spoken turn, orchestrated: listen → transcribe → ask DeepSeek → speak.
@MainActor
final class Conversation: ObservableObject {
    enum Phase: Equatable {
        case idle
        case listening
        case thinking
        case speaking
        case failed(String)
    }

    /// Speaking difficulty. A1 keeps turns to a handful of words and offers
    /// choices instead of open questions, which is what makes a session feel
    /// survivable at the very beginning.
    enum Level: String, CaseIterable, Identifiable {
        case a1 = "A1"
        case a2 = "A2"
        case b1 = "B1"

        var id: String { rawValue }

        var speechRate: Float {
            switch self {
            case .a1: 0.40
            case .a2: 0.46
            case .b1: 0.50
            }
        }

        var guidance: String {
            switch self {
            case .a1:
                return """
                Niveau A1. Antworte mit höchstens sechs Wörtern, nur Präsens, nur häufige Wörter.
                Stelle einfache Fragen, oft mit zwei Möglichkeiten: "Kaffee oder Tee?"
                Sage ich nur ein Wort, mache daraus in deiner Antwort einen ganzen Satz.
                Frage nie nach etwas, das ich noch nicht gesagt habe.
                """
            case .a2:
                return """
                Niveau A2. Antworte mit einem oder zwei kurzen Sätzen (höchstens zehn Wörter).
                Präsens und Perfekt. Genau eine einfache Frage pro Antwort.
                """
            case .b1:
                return """
                Niveau B1. Antworte mit zwei kurzen Sätzen und benutze Konnektoren
                (weil, deshalb, obwohl, wenn). Genau eine Frage pro Antwort.
                """
            }
        }
    }

    struct Scenario: Identifiable, Hashable {
        let id: String
        let title: String
        let setting: String

        static let all: [Scenario] = [
            .init(id: "cafe", title: "Im Café", setting: "Du bestellst etwas und plauderst mit der Bedienung."),
            .init(id: "hotel", title: "Im Hotel", setting: "Du checkst ein und fragst nach deinem Zimmer."),
            .init(id: "wohnung", title: "Wohnungssuche", setting: "Du besichtigst eine WG und stellst Fragen."),
            .init(id: "arzt", title: "Beim Arzt", setting: "Du beschreibst, was dir wehtut."),
            .init(id: "smalltalk", title: "Small Talk", setting: "Du triffst einen Nachbarn im Hof."),
            .init(id: "einkaufen", title: "Beim Einkaufen", setting: "Du kaufst ein und fragst nach einer Sache.")
        ]
    }

    @Published private(set) var messages: [ChatMessage] = []
    @Published private(set) var phase: Phase = .idle
    @Published var scenario: Scenario = Scenario.all[0]
    @Published var draft = ""
    @Published var level: Level {
        didSet { UserDefaults.standard.set(level.rawValue, forKey: Self.levelKey) }
    }

    let listener = GermanListener()
    let speaker = GermanSpeaker()

    private static let levelKey = "speakLevel"
    private var started = false

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.levelKey)
        level = Level(rawValue: stored ?? "") ?? .a1
    }

    private var systemPrompt: String {
        """
        Du bist mein deutscher Gesprächspartner. Szenario: \(scenario.title). \
        \(scenario.setting)

        Regeln:
        \(level.guidance)
        - Antworte immer auf Deutsch und wechsle nie ins Englische.
        - Macht mein Fehler die Bedeutung unklar, wiederhole meine Aussage beiläufig \
        korrekt, ohne zu erklären ("Ach, du bist also gestern gekommen?").
        - Keine Aufzählungen, keine Erklärungen, kein Lob.
        """
    }

    func begin() async {
        guard !started else { return }
        started = true
        await send()
    }

    func restart() async {
        messages = []
        started = false
        phase = .idle
        await begin()
    }

    /// Takes the microphone transcript or a typed line.
    func submit(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, phase != .thinking else { return }

        speaker.stop()
        messages.append(.user(trimmed))
        draft = ""
        await send()
    }

    /// Asks for a sentence the learner could say next — the difference between
    /// being stuck and being able to keep going.
    func hint() async {
        guard !messages.isEmpty, phase != .thinking else { return }
        speaker.stop()
        await send(
            instruction: """
            \(systemPrompt)

            Ich weiß gerade nicht weiter. Gib mir EINEN kurzen deutschen Satz, den ich jetzt \
            sagen könnte, passend zum Szenario und zu meinem Niveau — dann in Klammern die \
            englische Bedeutung. Sonst nichts.
            """
        )
    }

    /// Wraps up with corrections instead of continuing the roleplay.
    func finish() async {
        guard !messages.isEmpty else { return }
        speaker.stop()
        await send(
            instruction: """
            Beende das Gespräch kurz auf Deutsch (ein Satz), dann liste 2–3 Korrekturen \
            meiner Sätze im Format "ich: <mein Satz> → besser: <korrigiert>" und einen \
            Tipp. Maximal sechs Zeilen.
            """
        )
    }

    /// `instruction` replaces the roleplay prompt for one turn — used by the
    /// debrief, which must stop playing the part and start correcting.
    private func send(instruction: String? = nil) async {
        phase = .thinking

        var payload: [ChatMessage] = [.system(instruction ?? systemPrompt)]
        payload.append(contentsOf: messages)

        guard let key = Keychain.apiKey, !key.isEmpty else {
            phase = .failed(L10n.t("No API key — add one in Settings.", "Kein API-Schlüssel — bitte in den Einstellungen eintragen."))
            return
        }

        do {
            let reply = try await DeepSeekClient(apiKey: key).reply(to: payload)
            messages.append(.assistant(reply))
            phase = .speaking
            speaker.speak(reply, rate: level.speechRate)
            phase = .idle
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }

    func startListening() async {
        guard phase != .thinking else { return }
        speaker.stop()
        let allowed = await listener.requestAccess()
        guard allowed else {
            phase = .failed(listener.failure ?? L10n.t("Microphone not allowed.", "Mikrofon nicht erlaubt."))
            return
        }
        listener.start()
        // the listener publishes asynchronously now, so trust the
        // attempt here and let the orb reflect the real state
        phase = .listening
    }

    func stopListening() async {
        listener.stop()
        let spoken = listener.transcript
        phase = .idle
        await submit(spoken)
    }

    func fallbackSpeak(_ text: String) {
        speaker.speak(text)
    }
}
