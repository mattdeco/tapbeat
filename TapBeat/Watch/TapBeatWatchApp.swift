import SwiftUI

@main
struct TapBeatWatchApp: App {
    @StateObject private var session = TempoSession()

    var body: some Scene {
        WindowGroup {
            TapBeatWatchContentView(session: session)
        }
    }
}
