import SceneKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class LightingSetup {
    static func configureLighting(for scene: SCNScene) {
        if let path = Bundle.main.path(forResource: "Studio_Lighting", ofType: "hdr", inDirectory: "Skybox") {
            scene.lightingEnvironment.contents = path
            scene.background.contents = path
        } else {
            scene.background.contents = PlatformColor.systemYellow
            
            let directionalLight = SCNLight()
            directionalLight.type = .directional
            directionalLight.intensity = 1500
            directionalLight.castsShadow = true
            directionalLight.shadowMode = .forward
            directionalLight.shadowSampleCount = 8
            directionalLight.shadowMapSize = CGSize(width: 2048, height: 2048)
            
            let directionalNode = SCNNode()
            directionalNode.light = directionalLight
            directionalNode.eulerAngles = SCNVector3(-Float.pi / 2.5, -Float.pi / 4, 0)
            scene.rootNode.addChildNode(directionalNode)
        }
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 300
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.intensity = 1000
        let omniNode = SCNNode()
        omniNode.light = omniLight
        omniNode.position = SCNVector3(x: 0, y: 15, z: 0)
        scene.rootNode.addChildNode(omniNode)
    }
}
