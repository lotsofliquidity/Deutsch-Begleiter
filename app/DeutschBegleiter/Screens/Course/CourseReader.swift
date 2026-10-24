import SwiftUI
import DesignKit

/// Shared inline-markdown rendering. SwiftUI's `Text` accepts markdown only
/// through `LocalizedStringKey`; course strings are dynamic, so they go through
/// `AttributedString`.
public enum Markdown {
    public static func inline(_ text: String) -> AttributedString {
        (try? AttributedString(
            markdown: text,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )) ?? AttributedString(text)
    }
}

struct CourseReader: View {
    var title: String
    var subtitle: String?
    var blocks: [CourseBlock]
    var onBack: () -> Void

    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(spacing: 0) {
            HStack {
                BackChip(label: text.back, action: onBack)
                Spacer()
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)

            ScreenScroll {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        if let subtitle {
                            Text(subtitle)
                                .font(Typography.caption)
                                .foregroundStyle(t.success)
                        }
                        Text(Markdown.inline(title))
                            .font(Typography.display(26))
                            .foregroundStyle(t.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    ForEach(Array(blocks.enumerated()), id: \.offset) { _, block in
                        BlockView(block: block)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, Metrics.pad)
                .padding(.top, 10)
            }
        }
    }
}

struct BlockView: View {
    var block: CourseBlock
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        switch block {
        case .heading(let level, let text):
            Text(Markdown.inline(text))
                .font(level <= 2 ? Typography.title : Typography.headline)
                .foregroundStyle(t.ink)
                .padding(.top, level <= 2 ? 10 : 4)
                .fixedSize(horizontal: false, vertical: true)

        case .paragraph(let text):
            Text(Markdown.inline(text))
                .font(Typography.body)
                .foregroundStyle(t.ink.opacity(0.92))
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)

        case .list(let items):
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.depth == 0 ? "•" : "–")
                            .font(.system(size: item.depth == 0 ? 13 : 11, weight: .bold, design: .rounded))
                            .foregroundStyle(t.success.opacity(0.8))
                        Text(Markdown.inline(item.text))
                            .font(Typography.body)
                            .foregroundStyle(t.ink.opacity(item.depth == 0 ? 0.92 : 0.75))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.leading, CGFloat(item.depth) * 14)
                }
            }

        case .table(let header, let rows):
            TableBlock(header: header, rows: rows)

        case .callout(let text):
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(t.success)
                    .frame(width: 3)
                Text(Markdown.inline(text))
                    .font(Typography.body)
                    .foregroundStyle(t.ink.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 8)
            .padding(.trailing, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(t.surfaceSunken.opacity(0.8))
            )

        case .code(let text):
            Text(text)
                .font(.system(size: 12, design: .monospaced))
                .foregroundStyle(t.ink.opacity(0.85))
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(t.surfaceSunken)
                )
        }
    }
}

/// Tables carry most of the course, so they get first-class treatment:
/// grammatical gender columns are coloured, and chunk tables can hide their
/// meanings so they work as a self-test.
struct TableBlock: View {
    var header: [String]
    var rows: [[String]]

    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme
    @State private var hideMeanings = false
    @State private var revealed: Set<Int> = []

    /// Index of the "m" column when the header is a gender grid (m · f · n · pl).
    private var genderStart: Int? {
        guard
            let start = header.firstIndex(of: "m"),
            header.count > start + 3,
            Array(header[(start + 1)...(start + 3)]) == ["f", "n", "pl"]
        else { return nil }
        return start
    }

    private var isChunkTable: Bool {
        header.contains { $0.lowercased().contains("chunk") }
    }

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(alignment: .leading, spacing: 8) {
            if isChunkTable {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(Motion.press) {
                            hideMeanings.toggle()
                            revealed.removeAll()
                        }
                    } label: {
                        Chip(
                            hideMeanings ? text.showMeanings : text.hideMeanings,
                            symbol: hideMeanings ? "eye.slash" : "eye",
                            tint: t.surfaceSunken
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            if isChunkTable {
                chunkRows(t)
            } else {
                grid(t)
            }
        }
    }

    /// No horizontal `ScrollView` here: it does not draw its content offscreen
    /// (the snapshot harness) and the cells are short enough to wrap.
    private func grid(_ t: SceneTokens) -> some View {
        Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 6) {
            GridRow {
                ForEach(Array(header.enumerated()), id: \.offset) { index, cell in
                    Text(Markdown.inline(cell))
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(colour(for: index, cell: cell) ?? t.inkSoft)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(minWidth: index == 0 ? 86 : nil, alignment: .leading)
                }
            }
            Rectangle()
                .fill(t.ink.opacity(0.12))
                .frame(height: 1)
                .gridCellUnsizedAxes(.horizontal)
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                GridRow {
                    ForEach(Array(row.enumerated()), id: \.offset) { index, cell in
                        Text(Markdown.inline(cell))
                            .font(.system(size: 14, weight: index == 0 ? .semibold : .medium,
                                          design: .rounded))
                            .foregroundStyle(colour(for: index, cell: cell) ?? t.ink.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(minWidth: index == 0 ? 86 : nil, alignment: .leading)
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(t.surface.opacity(0.95))
        )
    }

    private func chunkRows(_ t: SceneTokens) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                let number = row.first ?? ""
                let german = row.count > 1 ? row[1] : ""
                let meaning = row.count > 2 ? row[2] : ""
                let hidden = hideMeanings && !revealed.contains(index)

                Button {
                    guard hideMeanings else { return }
                    withAnimation(Motion.press) {
                        if revealed.contains(index) {
                            revealed.remove(index)
                        } else {
                            revealed.insert(index)
                        }
                    }
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Text(number)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(t.inkSoft)
                            .frame(width: 20, alignment: .leading)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(Markdown.inline(german))
                                .font(Typography.body)
                                .foregroundStyle(t.ink)
                                .multilineTextAlignment(.leading)
                            Text(hidden ? "•••" : Markdown.inline(meaning))
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(hidden ? t.inkSoft.opacity(0.4) : t.inkSoft)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < rows.count - 1 {
                    Rectangle()
                        .fill(t.ink.opacity(0.06))
                        .frame(height: 1)
                        .padding(.leading, 34)
                }
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(t.surface.opacity(0.95))
        )
    }

    private func colour(for index: Int, cell: String) -> Color? {
        guard let start = genderStart, index >= start, index < start + 4 else { return nil }

        let plain = cell
            .replacingOccurrences(of: "*", with: "")
            .trimmingCharacters(in: .whitespaces)
        guard !plain.isEmpty, plain != "—" else { return nil }

        switch index - start {
        case 0: return NounColor.der
        case 1: return NounColor.die
        case 2: return NounColor.das
        default: return NounColor.plural
        }
    }
}
