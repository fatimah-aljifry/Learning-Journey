import SwiftUI

@main struct MyApp: App {
    /// The app's single store, created once and kept alive for the app's whole life.
    @State private var store = LearningStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Shares the store with every screen (read with @Environment(LearningStore.self)).
                .environment(store)
                // The whole app is always dark: keyboard, alerts and status bar match the black design.
                .preferredColorScheme(.dark)
                // App-wide brand color (#FF9230 in Dark Mode) for toolbar buttons, alerts, the text cursor, etc.
                .tint(.orange)
        }
    }
}
