import Foundation

struct ChatMessage: Codable, Equatable, Sendable {
    enum Role: String, Codable, Sendable {
        case system, user, assistant
    }

    var role: Role
    var content: String

    static func system(_ text: String) -> ChatMessage { .init(role: .system, content: text) }
    static func user(_ text: String) -> ChatMessage { .init(role: .user, content: text) }
    static func assistant(_ text: String) -> ChatMessage { .init(role: .assistant, content: text) }
}

/// Minimal DeepSeek chat client — OpenAI-compatible, one call per turn.
struct DeepSeekClient: Sendable {
    var apiKey: String
    var model: String = "deepseek-flash"
    var endpoint = URL(string: "https://api.deepseek.com/chat/completions")!

    enum Failure: LocalizedError {
        case missingKey
        case http(Int, String)
        case empty

        var errorDescription: String? {
            switch self {
            case .missingKey:
                return "No API key. Add one in Settings."
            case .http(let code, let body):
                switch code {
                case 401: return "The key was rejected (401)."
                case 402: return "The account is out of credit (402)."
                case 429: return "Rate limited (429). Try again."
                default: return "DeepSeek returned \(code): \(body.prefix(160))"
                }
            case .empty:
                return "DeepSeek returned an empty reply."
            }
        }
    }

    private struct Payload: Encodable {
        struct Message: Encodable {
            let role: String
            let content: String
        }
        let model: String
        let messages: [Message]
        let temperature: Double
        let max_tokens: Int
        let stream: Bool
    }

    private struct Response: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable { let content: String }
            let message: Message
        }
        let choices: [Choice]
    }

    func reply(to messages: [ChatMessage], temperature: Double = 1.3) async throws -> String {
        guard !apiKey.isEmpty else { throw Failure.missingKey }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 45
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let body = Payload(
            model: model,
            messages: messages.map { .init(role: $0.role.rawValue, content: $0.content) },
            temperature: temperature,
            max_tokens: 400,
            stream: false
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard code == 200 else {
            throw Failure.http(code, String(decoding: data, as: UTF8.self))
        }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        let text = decoded.choices.first?.message.content
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { throw Failure.empty }
        return text
    }

    /// One cheap call to prove the key works before a session starts.
    static func test(_ key: String) async -> String {
        let client = DeepSeekClient(apiKey: key)
        do {
            let reply = try await client.reply(
                to: [.system("Reply with exactly: OK"), .user("ping")],
                temperature: 0
            )
            return "Key works — \(reply.prefix(24))"
        } catch {
            return error.localizedDescription
        }
    }
}
