import SceneKit

protocol GameStateDelegate: AnyObject {
    func ballReachedTarget(ball: Int)
    func ballLeftTarget(ball: Int)
    func ballCollidedWithWall()
}

class PhysicsContactDelegate: NSObject, SCNPhysicsContactDelegate {
    weak var delegate: GameStateDelegate?
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let maskA = contact.nodeA.physicsBody?.categoryBitMask ?? 0
        let maskB = contact.nodeB.physicsBody?.categoryBitMask ?? 0
        let combined = maskA | maskB
        
        if combined == (PhysicsCategory.ballA | PhysicsCategory.endA) {
            delegate?.ballReachedTarget(ball: PhysicsCategory.ballA)
        } else if combined == (PhysicsCategory.ballC | PhysicsCategory.endC) {
            delegate?.ballReachedTarget(ball: PhysicsCategory.ballC)
        } else if combined == (PhysicsCategory.ballA | PhysicsCategory.wall) || combined == (PhysicsCategory.ballC | PhysicsCategory.wall) || combined == (PhysicsCategory.ballA | PhysicsCategory.ballC) {
            // Check for collision impulse to avoid buzzing endlessly when just rolling against a wall
            if contact.collisionImpulse > 0.5 {
                delegate?.ballCollidedWithWall()
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        let maskA = contact.nodeA.physicsBody?.categoryBitMask ?? 0
        let maskB = contact.nodeB.physicsBody?.categoryBitMask ?? 0
        let combined = maskA | maskB
        
        if combined == (PhysicsCategory.ballA | PhysicsCategory.endA) {
            delegate?.ballLeftTarget(ball: PhysicsCategory.ballA)
        } else if combined == (PhysicsCategory.ballC | PhysicsCategory.endC) {
            delegate?.ballLeftTarget(ball: PhysicsCategory.ballC)
        }
    }
}
