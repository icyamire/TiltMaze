import SwiftUI
import SceneKit
#if canImport(UIKit)
import UIKit

struct SceneViewContainer: UIViewRepresentable {
    @Binding var viscosity: CGFloat
    let sceneController: GameSceneController
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = sceneController.scene
        scnView.allowsCameraControl = false
        scnView.rendersContinuously = true
        scnView.backgroundColor = UIColor.systemYellow
        scnView.antialiasingMode = .multisampling4X
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        sceneController.updateBallsDamping(viscosity: viscosity)
    }
}
#elseif canImport(AppKit)
import AppKit

struct SceneViewContainer: NSViewRepresentable {
    @Binding var viscosity: CGFloat
    let sceneController: GameSceneController
    
    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = sceneController.scene
        scnView.allowsCameraControl = false
        scnView.rendersContinuously = true
        scnView.backgroundColor = NSColor.systemYellow
        scnView.antialiasingMode = .multisampling4X
        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        sceneController.updateBallsDamping(viscosity: viscosity)
    }
}
#endif
