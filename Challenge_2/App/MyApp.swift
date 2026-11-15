import SwiftUI

@main struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // The whole app is always dark: keyboard, alerts and status bar match the black design.
                .preferredColorScheme(.dark)
                // App-wide brand color (#FF9230 in Dark Mode) for toolbar buttons, alerts, the text cursor, etc.
                .tint(.orange)
        }
    }
}
