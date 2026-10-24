import SwiftUI
import DesignKit

@main
struct DeutschBegleiterApp: App {
    init() {
        #if os(macOS)
        if SelfTest.runIfRequested() { exit(0) }
        if Snapshot.runIfRequested() { exit(0) }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                #if os(macOS)
                .frame(minWidth: 420, minHeight: 680)
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 440, height: 860)
        #endif
    }
}
