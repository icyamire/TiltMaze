import SwiftUI

@main
struct MyApp: App {
    @State private var isGameActive = false
    @State private var selectedLevel = 1
    @State private var selectedMode: GameMode = .gravity
    
    var body: some Scene {
        WindowGroup {
            if isGameActive {
                MainGameView(initialLevel: selectedLevel, isGameActive: $isGameActive, currentMode: selectedMode)
            } else {
                StartMenuView(isGameActive: $isGameActive, startingLevel: $selectedLevel, selectedMode: $selectedMode)
            }
        }
    }
}
