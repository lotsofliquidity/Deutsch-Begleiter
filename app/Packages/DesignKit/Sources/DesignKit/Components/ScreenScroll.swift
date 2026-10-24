import SwiftUI

/// `ScrollView` does not draw its document view inside `ImageRenderer`, so the
/// snapshot pass renders the same content clipped to the frame instead.
@MainActor
public enum RenderMode {
    public static var isRendering = false
}

public struct ScreenScroll<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        if RenderMode.isRendering {
            GeometryReader { geo in
                VStack(spacing: 0) {
                    content
                    Spacer(minLength: 0)
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .clipped()
            }
        } else {
            ScrollView {
                content
            }
            .scrollIndicators(.hidden)
        }
    }
}

/// Renders a static placeholder while snapshotting; the real `SecureField` is
/// AppKit-backed and does not draw offscreen.
public struct SecretField: View {
    @Binding private var text: String
    private var placeholder: String
    @Environment(\.colorScheme) private var scheme

    public init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        let t = SceneTokens.resolve(scheme)

        Group {
            if RenderMode.isRendering {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(t.inkSoft)
                    Text(text.isEmpty ? placeholder : "sk-••••••••••••3f2a")
                        .foregroundStyle(text.isEmpty ? t.inkSoft : t.ink)
                    Spacer()
                }
            } else {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(.plain)
                    .foregroundStyle(t.ink)
            }
        }
        .font(Typography.body)
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(t.surfaceSunken)
        )
    }
}
