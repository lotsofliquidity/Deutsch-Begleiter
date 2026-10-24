import SwiftUI
import DesignKit

/// The course reader. One tab, three shelves: units, grammar rules, patterns —
/// all of it rendered from the bundled pack, so it works with no network.
struct CourseTab: View {
    @Environment(\.coursePack) private var pack: CoursePack

    @State private var shelf: Shelf = .units
    @State private var route: Route?

    enum Shelf: String, CaseIterable, Identifiable {
        case units, grammar, patterns
        var id: String { rawValue }
    }

    enum Route: Hashable {
        case unit(String)
        case rule(String)
        case pattern(String)
    }

    var body: some View {
        Group {
            if let route {
                reader(for: route)
            } else {
                CourseHome(shelf: $shelf, onOpen: { route = $0 })
            }
        }
        .animation(Motion.card, value: route)
    }

    @ViewBuilder
    private func reader(for route: Route) -> some View {
        switch route {
        case .unit(let id):
            if let unit = pack.unit(id) {
                CourseReader(
                    title: unit.title,
                    subtitle: unitSubtitle(unit),
                    blocks: unit.blocks
                ) { self.route = nil }
            } else {
                EmptyView()
            }
        case .rule(let id):
            if let rule = pack.rule(id) {
                CourseReader(
                    title: rule.title,
                    subtitle: "§\(rule.number)",
                    blocks: rule.blocks
                ) { self.route = nil }
            } else {
                EmptyView()
            }
        case .pattern(let id):
            if let pattern = pack.pattern(id) {
                CourseReader(title: pattern.title, subtitle: nil, blocks: pattern.blocks) {
                    self.route = nil
                }
            } else {
                EmptyView()
            }
        }
    }

    private func unitSubtitle(_ unit: CoursePack.Unit) -> String {
        let level = pack.levels.first { level in
            level.units.contains { $0.id == unit.id }
        }?.name ?? ""
        return "\(level) · Unit \(unit.number)"
    }
}

struct CourseHome: View {
    @Binding var shelf: CourseTab.Shelf
    var onOpen: (CourseTab.Route) -> Void

    @Environment(\.coursePack) private var pack: CoursePack
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme
    @State private var query = ""

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(text.tabCourse)
                    .font(Typography.display(30))
                    .foregroundStyle(t.ink)
                Spacer()
                Chip("\(totalUnits) \(text.units)", symbol: "book.closed.fill",
                     tint: Color(hex: 0xBFE0FF))
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)

            shelfPicker(t)

            ScreenScroll {
                VStack(spacing: 10) {
                    switch shelf {
                    case .units: unitShelf(t)
                    case .grammar: ruleShelf(t)
                    case .patterns: patternShelf(t)
                    }
                }
                .padding(.horizontal, Metrics.pad)
                .padding(.bottom, 24)
            }
        }
    }

    private var totalUnits: Int {
        pack.levels.reduce(0) { $0 + $1.units.count }
    }

    private func shelfPicker(_ t: SceneTokens) -> some View {
        HStack(spacing: 6) {
            ForEach(CourseTab.Shelf.allCases) { candidate in
                let isOn = candidate == shelf
                Button {
                    withAnimation(Motion.press) { shelf = candidate }
                } label: {
                    Text(label(for: candidate))
                        .font(Typography.caption)
                        .foregroundStyle(isOn ? t.ink : t.ink.opacity(0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(isOn ? t.accent.opacity(0.92) : Color.clear)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(t.surface.opacity(0.92))
        )
        .padding(.horizontal, Metrics.pad)
    }

    private func label(for shelf: CourseTab.Shelf) -> String {
        switch shelf {
        case .units: text.units
        case .grammar: text.grammar
        case .patterns: text.patterns
        }
    }

    @ViewBuilder
    private func unitShelf(_ t: SceneTokens) -> some View {
        ForEach(pack.levels) { level in
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(level.name)
                        .font(Typography.headline)
                        .foregroundStyle(t.ink)
                    Chip("\(level.units.count)", tint: Color(hex: 0xD9F0C4))
                }
                .padding(.top, 6)

                ForEach(level.units) { unit in
                    Button { onOpen(.unit(unit.id)) } label: {
                        ListRow(
                            title: unit.title,
                            detail: "Unit \(unit.number)"
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func ruleShelf(_ t: SceneTokens) -> some View {
        ForEach(pack.grammar) { rule in
            Button { onOpen(.rule(rule.id)) } label: {
                ListRow(title: rule.title, detail: "§\(rule.number)")
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func patternShelf(_ t: SceneTokens) -> some View {
        PlainField(placeholder: text.search, text: $query)
            .padding(.bottom, 2)

        ForEach(filteredPatterns) { pattern in
            Button { onOpen(.pattern(pattern.id)) } label: {
                ListRow(title: pattern.title, detail: nil)
            }
            .buttonStyle(.plain)
        }
    }

    private var filteredPatterns: [CoursePack.Pattern] {
        let needle = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !needle.isEmpty else { return pack.patterns }
        return pack.patterns.filter { $0.title.lowercased().contains(needle) }
    }
}

struct ListRow: View {
    var title: String
    var detail: String?
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)
        FloatCard(padding: 14) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(Typography.body)
                        .foregroundStyle(t.ink)
                        .multilineTextAlignment(.leading)
                    if let detail {
                        Text(detail)
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(t.inkSoft)
                    }
                }
                Spacer(minLength: 6)
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(t.ink.opacity(0.3))
            }
        }
    }
}
