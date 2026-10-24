import Foundation
import SwiftUI

/// The booklets, indexed by tools/export_booklet.py from each PDF's contents
/// page and page footers. Pages are 1-based PDF page numbers.
struct BookletIndex: Decodable {
    struct Booklet: Decodable, Identifiable {
        struct Unit: Decodable, Identifiable {
            struct Dialog: Decodable, Identifiable {
                let number: Int
                let title: String
                let start: Int
                let end: Int

                var id: Int { number }
            }

            let number: Int
            let title: String
            let setting: String
            let start: Int
            let end: Int
            let dialogs: [Dialog]

            var id: Int { number }
        }

        let id: String
        let name: String
        let file: String
        let pages: Int
        let units: [Unit]
    }

    let booklets: [Booklet]

    static let empty = BookletIndex(booklets: [])

    static func load(bundle: Bundle = .main) -> BookletIndex {
        guard
            let url = bundle.url(forResource: "index", withExtension: "json", subdirectory: "booklets")
                ?? bundle.url(forResource: "index", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let index = try? JSONDecoder().decode(BookletIndex.self, from: data)
        else {
            return .empty
        }
        return index
    }

    func booklet(_ id: String) -> Booklet? {
        booklets.first { $0.id == id }
    }

    /// Resolves the PDF that sits next to the index in the bundle.
    func document(for booklet: Booklet, bundle: Bundle = .main) -> URL? {
        bundle.url(forResource: booklet.id, withExtension: "pdf", subdirectory: "booklets")
            ?? bundle.url(forResource: booklet.id, withExtension: "pdf")
    }
}

private struct BookletIndexKey: EnvironmentKey {
    static let defaultValue = BookletIndex.empty
}

extension EnvironmentValues {
    var bookletIndex: BookletIndex {
        get { self[BookletIndexKey.self] }
        set { self[BookletIndexKey.self] = newValue }
    }
}
