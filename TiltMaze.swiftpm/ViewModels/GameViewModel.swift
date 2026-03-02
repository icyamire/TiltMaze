import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var liquidViscosity: CGFloat = 0.5
    
    @Published var isBallAInPlace: Bool = false
    @Published var isBallCInPlace: Bool = false
    @Published var isGameWon: Bool = false
    @Published var currentLevel: Int = 1
    
    @Published var elapsedTime: TimeInterval = 0
    private var gameTimer: Timer?
    
    var motionManager = MotionInputManager()
    
    init() {
        // Will start motionManager conditionally based on GameMode
    }
    
    deinit {
        motionManager.stop()
    }
    
    func resetGame(for mode: GameMode) {
        isBallAInPlace = false
        isBallCInPlace = false
        isGameWon = false
        
        if mode == .gravity {
            motionManager.start()
        } else {
            motionManager.stop()
        }
    }
    
    func startTimer() {
        gameTimer?.invalidate()
        elapsedTime = 0
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isGameWon else { return }
            self.elapsedTime += 1
        }
    }
    
    func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
}
