import SwiftUI
import DesignKit
import PDFKit

/// A unit, shown two ways: the real booklet pages, or the notes built from them.
/// The booklet is the default because re-typesetting loses the dialogue columns,
/// footnotes, cloze boxes and grammar tables the unit is actually made of.
struct UnitScreen: View {
    var unitID: String
    var onBack: () -> Void

    @Environment(\.coursePack) private var pack
    @Environment(\.bookletIndex) private var index
    @Environment(\.uiText) private var text
    @Environment(\.colorScheme) private var scheme

    @State private var mode: Mode = .booklet
    @State private var section: Int = 1

    enum Mode: String, CaseIterable, Identifiable {
        case booklet, notes
        var id: String { rawValue }
    }

    private var unit: CoursePack.Unit? { pack.unit(unitID) }

    /// `a1.1-u03` → booklet `a1.1`, unit `3`
    private var lookup: (booklet: BookletIndex.Booklet.Unit, file: URL)? {
        let parts = unitID.split(separator: "-")
        guard
            let level = parts.first.map(String.init),
            let number = Int(unitID.split(separator: "u").last ?? ""),
            let booklet = index.booklet(level),
            let entry = booklet.units.first(where: { $0.number == number }),
            let file = index.document(for: booklet)
        else { return nil }
        return (entry, file)
    }

    var body: some View {
        let t = SceneTokens.resolve(scheme)

        VStack(spacing: 10) {
            HStack(spacing: 10) {
                BackChip(label: text.back, action: onBack)
                Spacer()
                modePicker(t)
            }
            .padding(.horizontal, Metrics.pad)
            .padding(.top, 8)

            if let unit {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Markdown.inline(unit.title))
                        .font(Typography.title)
                        .foregroundStyle(t.ink)
                    if let lookup {
                        Text("Unit \(lookup.booklet.number) · \(lookup.booklet.setting)")
                            .font(Typography.caption)
                            .foregroundStyle(t.success)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Metrics.pad)
            }

            if let lookup, mode == .booklet {
                sectionPicker(lookup.booklet, t)
                PDFPane(url: lookup.file, page: currentPage(lookup.booklet))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .padding(.horizontal, 10)
                    .padding(.bottom, 6)
            } else if let unit {
                CourseReader(title: unit.title, subtitle: nil, blocks: unit.blocks, onBack: onBack)
            }
        }
    }

    private func currentPage(_ unit: BookletIndex.Booklet.Unit) -> Int {
        if section == 0 { return unit.start }
        return unit.dialogs.first { $0.number == section }?.start ?? unit.start
    }

    private func modePicker(_ t: SceneTokens) -> some View {
        HStack(spacing: 4) {
            ForEach(Mode.allCases) { candidate in
                let isOn = candidate == mode
                Button {
                    withAnimation(Motion.press) { mode = candidate }
                } label: {
                    Text(candidate == .booklet ? text.booklet : text.notes)
                        .font(Typography.caption)
                        .foregroundStyle(isOn ? t.ink : t.ink.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background {
                            Capsule().fill(isOn ? t.accent.opacity(0.9) : t.surface.opacity(0.85))
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func sectionPicker(_ unit: BookletIndex.Booklet.Unit, _ t: SceneTokens) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                sectionChip(0, text.overview, t)
                ForEach(unit.dialogs) { dialog in
                    sectionChip(dialog.number, "Dialog \(dialog.number)", t)
                }
            }
            .padding(.horizontal, Metrics.pad)
        }
        .scrollClipDisabled()
    }

    private func sectionChip(_ value: Int, _ label: String, _ t: SceneTokens) -> some View {
        let isOn = section == value
        return Button {
            withAnimation(Motion.press) { section = value }
        } label: {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(isOn ? .white : t.ink.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(Capsule().fill(isOn ? t.success : t.surface.opacity(0.9)))
        }
        .buttonStyle(.plain)
    }
}

/// PDFKit applies its own layout on first display, which cancels a `go(to:)`
/// issued during `updateUIView`. The jump is deferred one runloop turn and only
/// repeated when the requested page actually changes, so scrolling is never
/// fought.
final class PDFPaneCoordinator {
    var appliedPage: Int?
    var loadedURL: URL?
}

#if os(iOS)
struct PDFPane: UIViewRepresentable {
    let url: URL
    let page: Int

    func makeCoordinator() -> PDFPaneCoordinator { PDFPaneCoordinator() }

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.backgroundColor = .clear
        load(view, context.coordinator)
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) {
        load(view, context.coordinator)
    }

    private func load(_ view: PDFView, _ coordinator: PDFPaneCoordinator) {
        if coordinator.loadedURL != url {
            view.document = PDFDocument(url: url)
            coordinator.loadedURL = url
            coordinator.appliedPage = nil
        }
        guard coordinator.appliedPage != page else { return }
        coordinator.appliedPage = page
        guard let target = view.document?.page(at: max(0, page - 1)) else { return }
        DispatchQueue.main.async { view.go(to: target) }
    }
}
#else
struct PDFPane: NSViewRepresentable {
    let url: URL
    let page: Int

    func makeCoordinator() -> PDFPaneCoordinator { PDFPaneCoordinator() }

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        load(view, context.coordinator)
        return view
    }

    func updateNSView(_ view: PDFView, context: Context) {
        load(view, context.coordinator)
    }

    private func load(_ view: PDFView, _ coordinator: PDFPaneCoordinator) {
        if coordinator.loadedURL != url {
            view.document = PDFDocument(url: url)
            coordinator.loadedURL = url
            coordinator.appliedPage = nil
        }
        guard coordinator.appliedPage != page else { return }
        coordinator.appliedPage = page
        guard let target = view.document?.page(at: max(0, page - 1)) else { return }
        DispatchQueue.main.async { view.go(to: target) }
    }
}
#endif
