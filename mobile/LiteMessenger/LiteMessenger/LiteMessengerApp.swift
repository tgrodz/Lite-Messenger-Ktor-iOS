import SwiftUI

@main
struct LiteMessengerApp: App {
    @StateObject private var session = SessionViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}

