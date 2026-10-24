import Foundation
import SwiftUI

/// One block of course material. Markdown is parsed into these at export time
/// because SwiftUI text cannot lay out tables, and the course is thousands of
/// table rows deep.
enum CourseBlock: Decodable {
    case heading(level: Int, text: String)
    case paragraph(text: String)
    case list(items: [CourseItem])
    case table(header: [String], rows: [[String]])
    case callout(text: String)
    case code(text: String)

    private enum CodingKeys: String, CodingKey {
        case type, level, text, items, header, rows
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(String.self, forKey: .type) {
        case "heading":
            self = .heading(
                level: try container.decode(Int.self, forKey: .level),
                text: try container.decode(String.self, forKey: .text)
            )
        case "paragraph":
            self = .paragraph(text: try container.decode(String.self, forKey: .text))
        case "list":
            self = .list(items: try container.decode([CourseItem].self, forKey: .items))
        case "table":
            self = .table(
                header: try container.decode([String].self, forKey: .header),
                rows: try container.decode([[String]].self, forKey: .rows)
            )
        case "callout":
            self = .callout(text: try container.decode(String.self, forKey: .text))
        case "code":
            self = .code(text: try container.decode(String.self, forKey: .text))
        default:
            self = .paragraph(text: "")
        }
    }
}

struct CourseItem: Decodable {
    let text: String
    let depth: Int
}

struct CoursePack: Decodable {
    struct Level: Decodable, Identifiable {
        let id: String
        let name: String
        let units: [Unit]
    }

    struct Unit: Decodable, Identifiable {
        let id: String
        let number: Int
        let title: String
        let blocks: [CourseBlock]
    }

    struct Rule: Decodable, Identifiable {
        let id: String
        let number: Int
        let title: String
        let blocks: [CourseBlock]
    }

    struct Pattern: Decodable, Identifiable {
        let id: String
        let title: String
        let blocks: [CourseBlock]
    }

    let levels: [Level]
    let grammar: [Rule]
    let patterns: [Pattern]
}

extension CoursePack {
    static let empty = CoursePack(levels: [], grammar: [], patterns: [])

    /// Bundled content, exported from the course markdown by
    /// tools/export_course.py.
    static func load(bundle: Bundle = .main) -> CoursePack {
        guard
            let url = bundle.url(forResource: "course", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let pack = try? JSONDecoder().decode(CoursePack.self, from: data)
        else {
            return .empty
        }
        return pack
    }

    func unit(_ id: String) -> Unit? {
        levels.flatMap(\.units).first { $0.id == id }
    }

    func rule(_ id: String) -> Rule? {
        grammar.first { $0.id == id }
    }

    func pattern(_ id: String) -> Pattern? {
        patterns.first { $0.id == id }
    }
}

private struct CoursePackKey: EnvironmentKey {
    static let defaultValue = CoursePack.empty
}

extension EnvironmentValues {
    var coursePack: CoursePack {
        get { self[CoursePackKey.self] }
        set { self[CoursePackKey.self] = newValue }
    }
}
