import SceneKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class NodeFactory {
    static let ballRadius: CGFloat = 0.35
    
    static func createLiquidBall(categoryBitMask: Int, color: PlatformColor) -> SCNNode {
        let sphere = SCNSphere(radius: ballRadius)
        sphere.materials = [MaterialBuilder.buildLiquidGlassMaterial(color: color)]
        
        let node = SCNNode(geometry: sphere)
        let shape = SCNPhysicsShape(geometry: sphere, options: nil)
        let body = SCNPhysicsBody(type: .dynamic, shape: shape)
        
        body.categoryBitMask = categoryBitMask
        body.collisionBitMask = PhysicsCategory.wall | PhysicsCategory.ballA | PhysicsCategory.ballC | PhysicsCategory.floor
        body.contactTestBitMask = PhysicsCategory.endA | PhysicsCategory.endC
        
        body.mass = 1.0
        body.restitution = 0.2
        body.friction = 0.6
        body.rollingFriction = 0.1
        body.damping = 0.5 
        
        node.physicsBody = body
        return node
    }
    
    static func createWall(width: CGFloat, height: CGFloat, length: CGFloat) -> SCNNode {
        let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0.05)
        box.materials = [MaterialBuilder.buildWallMaterial()]
        
        let node = SCNNode(geometry: box)
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        let body = SCNPhysicsBody(type: .static, shape: shape)
        
        body.categoryBitMask = PhysicsCategory.wall
        node.physicsBody = body
        return node
    }
    
    static func createFloor(width: CGFloat, length: CGFloat, centerX: CGFloat, centerZ: CGFloat) -> SCNNode {
        // Floor height increased to 5.0 to prevent high speed physics tunneling during AR updates
        let box = SCNBox(width: width, height: 5.0, length: length, chamferRadius: 0)
        box.materials = [MaterialBuilder.buildFloorMaterial()]
        
        let node = SCNNode(geometry: box)
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        let body = SCNPhysicsBody(type: .static, shape: shape)
        
        body.categoryBitMask = PhysicsCategory.floor
        body.collisionBitMask = PhysicsCategory.ballA | PhysicsCategory.ballC
        
        node.physicsBody = body
        // Offset so floor top is at y=0 (5.0 / 2 = 2.5 downwards from center)
        node.position = SCNVector3(centerX, -2.5, centerZ)
        
        return node
    }
    
    static func createTargetZone(categoryBitMask: Int, color: PlatformColor, size: CGFloat) -> SCNNode {
        // Use a flat box instead of a cylinder to fill the entire corridor
        let box = SCNBox(width: size, height: 0.1, length: size, chamferRadius: 0.0)
        box.materials = [MaterialBuilder.buildTargetMaterial(color: color)]
        
        let node = SCNNode(geometry: box)
        let shape = SCNPhysicsShape(geometry: box, options: nil)
        
        let body = SCNPhysicsBody(type: .kinematic, shape: shape)
        body.categoryBitMask = categoryBitMask
        body.collisionBitMask = PhysicsCategory.none 
        body.contactTestBitMask = PhysicsCategory.ballA | PhysicsCategory.ballC
        
        node.physicsBody = body
        return node
    }
    
    #if canImport(UIKit)
    static func imageFrom(emoji: String, size: CGFloat) -> UIImage? {
        let nsString = emoji as NSString
        let font = UIFont.systemFont(ofSize: size)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let stringSize = nsString.size(withAttributes: attributes)
        
        UIGraphicsBeginImageContextWithOptions(stringSize, false, 0)
        nsString.draw(in: CGRect(origin: .zero, size: stringSize), withAttributes: attributes)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    #elseif canImport(AppKit)
    static func imageFrom(emoji: String, size: CGFloat) -> NSImage? {
        let nsString = emoji as NSString
        let font = NSFont.systemFont(ofSize: size)
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let stringSize = nsString.size(withAttributes: attributes)
        
        let image = NSImage(size: stringSize)
        image.lockFocus()
        nsString.draw(in: NSRect(origin: .zero, size: stringSize), withAttributes: attributes)
        image.unlockFocus()
        return image
    }
    #endif
    
    static func createEmojiNode(emoji: String, size: CGFloat = 1.0) -> SCNNode {
        // Render emoji string to a 2D image
        let image = imageFrom(emoji: emoji, size: 60)
        
        // Create a flat plane to display the image
        let plane = SCNPlane(width: size, height: size)
        let material = SCNMaterial()
        material.diffuse.contents = image
        material.isDoubleSided = true
        material.lightingModel = .constant // Unlit so it is always visible
        plane.materials = [material]
        
        let node = SCNNode(geometry: plane)
        
        // Add physics so it falls via gravity and bounces
        let shape = SCNPhysicsShape(geometry: plane, options: [SCNPhysicsShape.Option.type: SCNPhysicsShape.ShapeType.boundingBox])
        let body = SCNPhysicsBody(type: .dynamic, shape: shape)
        body.mass = 0.5
        body.restitution = 0.6 // Bouncy
        body.friction = 0.5
        body.categoryBitMask = PhysicsCategory.none
        body.collisionBitMask = PhysicsCategory.floor | PhysicsCategory.wall
        
        node.physicsBody = body
        return node
    }
}
