import SwiftUI

/// Chrome only — buttons, labels and section frames. Everything the learner is
/// meant to read as German material stays German regardless of this setting.
enum UILanguage: String, CaseIterable, Identifiable, Sendable {
    case en, de

    var id: String { rawValue }

    var label: String {
        switch self {
        case .en: "English"
        case .de: "Deutsch"
        }
    }
}

struct UIText: Sendable {
    var language: UILanguage = .en

    private func t(_ english: String, _ german: String) -> String {
        language == .en ? english : german
    }

    // MARK: tabs

    var tabHome: String { t("Home", "Heim") }
    var tabSpeak: String { t("Speak", "Sprechen") }
    var tabGrammar: String { t("Grammar", "Grammatik") }
    var tabCards: String { t("Cards", "Karten") }
    var tabSettings: String { t("Settings", "Einstellungen") }

    // MARK: home

    var hello: String { t("Hello!", "Servus!") }
    var dueToday: String { t("Due today", "Heute fällig") }
    var letsGo: String { t("Let's go", "Los geht's") }
    var reviews: String { t("Reviews", "Wiederholungen") }
    var cards: String { t("Cards", "Karten") }
    var speaking: String { t("Speaking", "Sprechen") }
    var sayItOutLoud: String { t("Say it out loud", "Sag es laut") }
    var sayItOutLoudDetail: String {
        t("Dackel asks, you answer — no looking things up.",
          "Dackel fragt, du antwortest — kein Nachlesen.")
    }
    var streak: String { t("Streak", "Serie") }
    var fromReviewLog: String { t("Review log", "Wiederholungs-Log") }
    var reviewLog: String { t("Review log", "Wiederholungs-Log") }
    var reviews_total: String { t("reviews", "Wiederholungen") }
    var localDatabase: String { t("Stored on this device", "Auf diesem Gerät gespeichert") }
    var unitLabel: String { t("Unit", "Einheit") }

    // MARK: speak

    var justStartTalking: String { t("Just start talking — or tap Hint.", "Sprich einfach los — oder tippe Tipp.") }
    var hint: String { t("Hint", "Tipp") }
    var again: String { t("Again", "Nochmal") }
    var slower: String { t("Slower", "Langsamer") }

    // MARK: grammar

    var grammarSubtitle: String {
        t("15 rules · each with examples and its unit", "15 Regeln · jede mit Beispiel und Einheit")
    }
    var plural: String { t("Plural", "Plural") }

    // MARK: cards

    var newDeck: String { t("New deck", "Neues Deck") }
    var study: String { t("Study", "Lernen") }
    var edit: String { t("Edit", "Bearbeiten") }
    var delete: String { t("Delete", "Löschen") }
    var done: String { t("Done", "Fertig") }
    var cancel: String { t("Cancel", "Abbrechen") }
    var back: String { t("Back", "Zurück") }
    var good: String { t("Good", "Gut") }
    var easy: String { t("Easy", "Leicht") }
    var predefined: String { t("Built in", "Mitgeliefert") }
    var custom: String { t("Yours", "Eigene") }
    var preview: String { t("preview", "Vorschau") }
    var cardsCount: String { t("cards", "Karten") }
    var deckName: String { t("Deck name", "Name des Decks") }
    var level: String { t("Level", "Niveau") }
    var addCard: String { t("Add card", "Karte hinzufügen") }
    var front: String { t("German — front", "Deutsch — Vorderseite") }
    var backSide: String { t("English — back", "Englisch — Rückseite") }
    var pasteTSV: String { t("Paste TSV", "TSV einfügen") }
    var importCards: String { t("Import", "Importieren") }
    var noB1: String { t("No B1 cards yet", "Noch keine B1-Karten") }
    var noB1Detail: String {
        t("Add a B1 booklet to the course folder and ingest it — the pack builds itself.",
          "Füge ein B1-Heft zum Kursordner hinzu und ingeste es — das Paket baut sich selbst.")
    }
    var noCustomDecks: String { t("No decks of your own yet", "Noch keine eigenen Decks") }
    var packMissing: String { t("No pack bundled", "Kein Paket enthalten") }
    var packMissingDetail: String {
        t("Run tools/export_brainscape.py to build it from the Brainscape deck.",
          "Führe tools/export_brainscape.py aus, um es aus dem Brainscape-Deck zu bauen.")
    }
    var nothingToStudy: String { t("This deck has no cards", "Dieses Deck hat keine Karten") }
    var deckNameRequired: String { t("Give the deck a name first", "Gib dem Deck zuerst einen Namen") }

    // MARK: settings

    var packs: String { t("Card packs", "Kartenpakete") }
    var update: String { t("Update", "Aktualisieren") }
    var updateURL: String { t("Pack source", "Quelle der Pakete") }
    var apiKey: String { t("API key", "Schlüssel") }
    var apiKeyDetail: String {
        t("Stays in this device's keychain.", "Bleibt im Schlüsselbund dieses Geräts.")
    }
    var test: String { t("Test", "Testen") }
    var appLanguage: String { t("App language", "Sprache der App") }
    var installed: String { t("Installed", "Installiert") }
    var notInstalled: String { t("Not available", "Nicht verfügbar") }
    var unlevelled: String { t("10 cards unlevelled", "10 Karten ohne Niveau") }
}

private struct UITextKey: EnvironmentKey {
    static let defaultValue = UIText()
}

extension EnvironmentValues {
    var uiText: UIText {
        get { self[UITextKey.self] }
        set { self[UITextKey.self] = newValue }
    }
}
