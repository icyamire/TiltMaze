import SwiftUI
import SceneKit
import ARKit

#if canImport(UIKit)
struct ARFaceSceneViewContainer: UIViewRepresentable {
    @Binding var viscosity: CGFloat
    let sceneController: GameSceneController
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        // 1. AR View for background camera feed and face tracking
        let arView = ARSCNView()
        arView.delegate = context.coordinator
        let config = ARFaceTrackingConfiguration()
        arView.session.run(config)
        // We do not assign our sceneController.scene to arView.
        // It remains empty, just rendering the camera background.
        
        // 2. SceneKit View for the actual stable game overlay
        let scnView = SCNView()
        scnView.scene = sceneController.scene
        scnView.pointOfView = sceneController.cameraNode
        scnView.backgroundColor = .clear // Transparent to see AR background
        scnView.autoenablesDefaultLighting = true
        scnView.antialiasingMode = .multisampling4X
        
        // Setup layout constraints
        arView.translatesAutoresizingMaskIntoConstraints = false
        scnView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(arView)
        containerView.addSubview(scnView)
        
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: containerView.topAnchor),
            arView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            arView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            scnView.topAnchor.constraint(equalTo: containerView.topAnchor),
            scnView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            scnView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            scnView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // Ensure standard gravity and scale since SceneKit is isolated from AR scale
        sceneController.resetGravity()
        sceneController.mazeContainerNode.scale = SCNVector3(1, 1, 1)
        
        // Ensure the scene background is totally clear so the video feed passes through
        sceneController.scene.background.contents = UIColor.clear
        
        // Provide scene controller to coordinator for gravity updates
        context.coordinator.sceneController = sceneController
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        sceneController.updateBallsDamping(viscosity: viscosity)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        weak var sceneController: GameSceneController?
        
        // Calibration offsets
        private var pitchOffset: Double = 0.0
        private var rollOffset: Double = 0.0
        private var hasCalibrated = false
        
        func calibrate(with node: SCNNode) {
            pitchOffset = Double(node.eulerAngles.x)
            rollOffset = Double(node.eulerAngles.z)
            hasCalibrated = true
            
            #if canImport(UIKit)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
        }
        
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            return anchor is ARFaceAnchor ? SCNNode() : nil
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARFaceAnchor, let scnController = sceneController else { return }
            
            // Auto-calibrate on first face detection
            if !hasCalibrated {
                calibrate(with: node)
            }
            
            // The face node's relative eulerAngles (subtracting the baseline calibration)
            let pitch = Double(node.eulerAngles.x) - pitchOffset
            let roll = Double(node.eulerAngles.z) - rollOffset
            
            // Apply gravity to the isolated SceneKit physics world
            // We removed the negative sign to flip the ball's rolling behavior back
            scnController.applyGravity(pitch: pitch, roll: roll)
            
            // Visually tilt the maze gently (same as classical mode effect in MainGameView)
            // Since we flipped `roll` to fix physics, we must flip the visual rotation back 
            // so the maze tips "down" towards the direction the ball rolls.
            DispatchQueue.main.async {
                scnController.mazeContainerNode.eulerAngles = SCNVector3(
                    Float(pitch) * 0.5,
                    0,
                    Float(-roll) * 0.5
                )
            }
        }
    }
}
#elseif canImport(AppKit)
import AppKit

// ARKit Face Tracking is not available on macOS Catalyst / native Mac without special setup,
// and ARSCNView is iOS-only. So we provide a fallback.
struct ARFaceSceneViewContainer: NSViewRepresentable {
    @Binding var viscosity: CGFloat
    let sceneController: GameSceneController
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let label = NSTextField(labelWithString: "AR Face Tracking is only available on iOS devices with TrueDepth cameras.")
        label.frame = NSRect(x: 20, y: 20, width: 400, height: 50)
        view.addSubview(label)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif
