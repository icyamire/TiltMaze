import SwiftUI

struct MainGameView: View {
    @StateObject private var viewModel = GameViewModel()
    @StateObject private var sceneController = GameSceneController()
    
    let initialLevel: Int
    @Binding var isGameActive: Bool
    
    let currentMode: GameMode
    
    init(initialLevel: Int, isGameActive: Binding<Bool>, currentMode: GameMode = .gravity) {
        self.initialLevel = initialLevel
        self._isGameActive = isGameActive
        self.currentMode = currentMode
    }
    
    // CoreMotion 60Hz update timer
    let timer = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // 3D Scene Layer
            if currentMode == .arFace {
                ARFaceSceneViewContainer(viscosity: $viewModel.liquidViscosity, sceneController: sceneController)
                    .edgesIgnoringSafeArea(.all)
            } else {
                SceneViewContainer(viscosity: $viewModel.liquidViscosity, sceneController: sceneController)
                    .edgesIgnoringSafeArea(.all)
            }
            // UI Overlay
            VStack {
                ZStack(alignment: .topLeading) {
                    HUDOverlayView(
                        currentLevel: viewModel.currentLevel,
                        isBallAReady: viewModel.isBallAInPlace,
                        isBallCReady: viewModel.isBallCInPlace,
                        isWin: viewModel.isGameWon,
                        elapsedTime: viewModel.elapsedTime
                    )
                    
                    Button(action: {
                        isGameActive = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .foregroundColor(.primary)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 20)
                }
                
                Spacer()
                
                if viewModel.isGameWon {
                    Button(action: {
                        viewModel.currentLevel += 1
                        sceneController.resetLevel(level: viewModel.currentLevel)
                        viewModel.startTimer()
                    }) {
                        Text("Next Level")
                            .font(.title2)
                            .bold()
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .padding(.bottom, 20)
                }
                
                SensitivityControlView(viscosity: $viewModel.liquidViscosity)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            viewModel.currentLevel = initialLevel
            viewModel.resetGame(for: currentMode)
            sceneController.resetLevel(level: initialLevel)
            
            sceneController.onBallReadyStateChanged = { a, c in
                viewModel.isBallAInPlace = a
                viewModel.isBallCInPlace = c
            }
            sceneController.onWinStateChanged = { won in
                viewModel.isGameWon = won
                if won {
                    viewModel.stopTimer()
                }
            }
            
            // Start initial timer
            viewModel.startTimer()
        }
        .onReceive(timer) { _ in
            if currentMode == .gravity {
                sceneController.applyGravity(
                    pitch: viewModel.motionManager.pitch,
                    roll: viewModel.motionManager.roll
                )
            }
        }
    }
}
