import SwiftUI

@main
struct TapBeatIOSApp: App {
    @StateObject private var session = TempoSession()

    var body: some Scene {
        WindowGroup {
            TapBeatIOSContentView(session: session)
                .preferredColorScheme(.dark)
        }
    }
}
