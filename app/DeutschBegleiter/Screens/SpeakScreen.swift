import SwiftUI
import DesignKit

struct SpeakScreen: View {
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme
    @Environment(\.coursePack) private var pack
    @StateObject private var chat = Conversation()

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(spacing: 0) {
            header(t)
            scenarioPicker(t)
            transcript(t)
            controls(t)
        }
        .task {
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("--probe-audio") {
                await chat.listener.probeTap()
            }
            #endif
            await chat.begin()
        }
    }

    private func header(_ t: SceneTokens) -> some View {
        HStack(alignment: .center) {
            Text(text.speaking)
                .font(Typography.display(28))
                .foregroundStyle(t.ink)
            Spacer()
            levelPicker(t)
        }
        .padding(.horizontal, Metrics.pad)
        .padding(.top, 8)
    }

    /// Level is the one control that changes how hard the tutor is, so it sits
    /// in the header rather than behind a menu.
    private func levelPicker(_ t: SceneTokens) -> some View {
        HStack(spacing: 4) {
            ForEach(Conversation.Level.allCases) { candidate in
                let isOn = candidate == chat.level
                Button {
                    guard !isOn else { return }
                    chat.level = candidate
                    Task { await chat.restart() }
                } label: {
                    Text(candidate.rawValue)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(isOn ? .white : t.ink.opacity(0.6))
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background {
                            Capsule().fill(isOn ? t.ink.opacity(0.85) : t.surface.opacity(0.9))
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func scenarioPicker(_ t: SceneTokens) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Conversation.Scenario.all) { scenario in
                    let isOn = scenario == chat.scenario
                    Button {
                        chat.scenario = scenario
                        Task { await chat.restart() }
                    } label: {
                        Text(scenario.title)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(isOn ? .white : t.ink.opacity(0.65))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(isOn ? t.success : t.surface.opacity(0.9)))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Metrics.pad)
        }
        .scrollClipDisabled()
        .padding(.top, 8)
    }

    private func transcript(_ t: SceneTokens) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(chat.messages.enumerated()), id: \.offset) { _, message in
                        if message.role != .system {
                            SpeechBubble(
                                message.content,
                                speaker: message.role == .assistant ? .tutor : .you,
                                speaks: message.role == .assistant
                            )
                            .id(message.content)
                        }
                    }

                    if case .thinking = chat.phase {
                        HStack(spacing: 6) {
                            ProgressView().controlSize(.small)
                            Text(text.thinking)
                                .font(Typography.caption)
                                .foregroundStyle(t.inkSoft)
                        }
                        .padding(.leading, 4)
                    }

                    if case .listening = chat.phase, !chat.listener.transcript.isEmpty {
                        SpeechBubble(chat.listener.transcript, speaker: .you)
                    }

                    if case .failed(let message) = chat.phase {
                        Text(message)
                            .font(Typography.caption)
                            .foregroundStyle(t.error)
                            .padding(.horizontal, 4)
                    }

                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, Metrics.pad)
                .padding(.top, 12)
            }
            .onChange(of: chat.messages.count) {
                withAnimation(Motion.card) { proxy.scrollTo("bottom", anchor: .bottom) }
            }
        }
    }

    private func controls(_ t: SceneTokens) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Dackel(mood: chat.phase == .listening ? .listening : .idle)
                    .frame(width: 74, height: 37)

                Button {
                    Task {
                        if chat.phase == .listening {
                            await chat.stopListening()
                        } else {
                            await chat.startListening()
                        }
                    }
                } label: {
                    SpeechOrb(
                        level: chat.listener.level,
                        isListening: chat.phase == .listening,
                        size: 158
                    )
                }
                .buttonStyle(.plain)
                .disabled(chat.phase == .thinking)

                Button {
                    Task { await chat.hint() }
                } label: {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(t.ink)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(t.surface.opacity(0.92)))
                }
                .buttonStyle(.plain)
                .disabled(chat.messages.isEmpty || chat.phase == .thinking)

                Button {
                    Task { await chat.finish() }
                } label: {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(t.ink)
                        .frame(width: 42, height: 42)
                        .background(Circle().fill(t.surface.opacity(0.92)))
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 8) {
                PlainField(placeholder: text.typeInstead, text: $chat.draft)
                Button {
                    Task { await chat.submit(chat.draft) }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(t.ink)
                        .frame(width: 38, height: 38)
                        .background(Circle().fill(t.accent))
                }
                .buttonStyle(.plain)
                .disabled(chat.draft.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, Metrics.pad)

            Text(hint)
                .font(Typography.caption)
                .foregroundStyle(t.ink.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, Metrics.pad)
        }
        .padding(.bottom, 8)
    }

    private var hint: String {
        switch chat.phase {
        case .listening: text.listeningNow
        case .thinking: text.thinking
        case .speaking, .idle: text.tapToSpeak
        case .failed: text.tapToSpeak
        }
    }
}
