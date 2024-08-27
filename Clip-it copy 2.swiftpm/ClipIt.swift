import SwiftUI
import SwiftData
import TipKit

@main
struct ClipIt: App {
    @State var launchIsShown = true
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
        .modelContainer(for: [AudioRecording.self, PhotoClip.self])
    }
}
