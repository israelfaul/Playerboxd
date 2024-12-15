import SwiftUI

@main
struct PlayerboxdApp: App {
    // Create an instance of GameStore
    @StateObject private var gameStore = GameStore()

    var body: some Scene {
        WindowGroup {
            // Pass the gameStore instance to HomeView
            HomeView(gameStore: gameStore)
        }
    }
}
