import SceneKit
#if canImport(UIKit)
import UIKit
#endif

class GameSceneController: ObservableObject, GameStateDelegate {
    let scene: SCNScene
    private let contactDelegate = PhysicsContactDelegate()
    
    private var ballANode: SCNNode?
    private var ballCNode: SCNNode?
    private var emojiNodes: [SCNNode] = []
    private var emojiSpawnTimer: Timer?
    
    // Node to hold the entire maze when attaching to an ARFaceAnchor
    let mazeContainerNode: SCNNode

    
    var onWinStateChanged: ((Bool) -> Void)?
    var onBallReadyStateChanged: ((Bool, Bool) -> Void)?
    
    private var ballAReady = false
    private var ballCReady = false
    
    init() {
        scene = SCNScene()
        mazeContainerNode = SCNNode()
        scene.rootNode.addChildNode(mazeContainerNode)
        
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        
        contactDelegate.delegate = self
        scene.physicsWorld.contactDelegate = contactDelegate
        
        LightingSetup.configureLighting(for: scene)
        setupCamera()
        generateLevel()
    }
    
    var cameraNode: SCNNode?
    
    private func setupCamera() {
        let node = SCNNode()
        node.camera = SCNCamera()
        node.eulerAngles = SCNVector3(-Float.pi / 2.5, 0, 0)
        scene.rootNode.addChildNode(node)
        self.cameraNode = node
    }
    
    func resetLevel(level: Int = 1) {
        ballAReady = false
        ballCReady = false
        
        emojiSpawnTimer?.invalidate()
        emojiSpawnTimer = nil
        emojiNodes.forEach { $0.removeFromParentNode() }
        emojiNodes.removeAll()
        
        ballANode?.removeFromParentNode()
        ballANode = nil
        ballCNode?.removeFromParentNode()
        ballCNode = nil
        
        onBallReadyStateChanged?(false, false)
        onWinStateChanged?(false)
        generateLevel(level: level)
    }
    
    private func generateLevel(level: Int = 1) {
        // Clear old geometry nodes
        mazeContainerNode.childNodes.forEach { 
            if $0.camera == nil && $0.light == nil { $0.removeFromParentNode() } 
        }
        
        let size = min(8 + (level - 1), 15)
        #if os(macOS)
        cameraNode?.position = SCNVector3(x: 0, y: CGFloat(15 + (size - 8) * 2), z: CGFloat(8 + (size - 8) - 2))
        #else
        cameraNode?.position = SCNVector3(x: 0, y: Float(15 + (size - 8) * 2), z: Float(8 + (size - 8) - 2))
        #endif
        let maze = MazeGenerator2D.generate(width: size, height: size)
        let cellSize: CGFloat = 1.0
        let wallThickness: CGFloat = 0.1
        
        let offsetX = -CGFloat(maze.width) * cellSize / 2.0
        let offsetZ = -CGFloat(maze.height) * cellSize / 2.0
        
        // Generate a larger floor to ensure balls don't fall off the edge when spawning or hitting outer walls
        let floorWidth = CGFloat(maze.width) * cellSize + 10.0
        let floorLength = CGFloat(maze.height) * cellSize + 10.0
        // The maze is centered at (0, 0), so the floor center is (0, 0)
        let floor = NodeFactory.createFloor(width: floorWidth, length: floorLength, centerX: 0, centerZ: 0)
        mazeContainerNode.addChildNode(floor)
        
        for x in 0..<maze.width {
            for y in 0..<maze.height {
                let cell = maze.cells[x][y]
                let px = offsetX + CGFloat(x) * cellSize + cellSize / 2.0
                let pz = offsetZ + CGFloat(y) * cellSize + cellSize / 2.0
                
                if cell.topWall {
                    let wall = NodeFactory.createWall(width: cellSize + wallThickness, height: 1.0, length: wallThickness)
                    wall.position = SCNVector3(px, 0.5, pz - cellSize / 2.0)
                    mazeContainerNode.addChildNode(wall)
                }
                if cell.bottomWall {
                    let wall = NodeFactory.createWall(width: cellSize + wallThickness, height: 1.0, length: wallThickness)
                    wall.position = SCNVector3(px, 0.5, pz + cellSize / 2.0)
                    mazeContainerNode.addChildNode(wall)
                }
                if cell.leftWall {
                    let wall = NodeFactory.createWall(width: wallThickness, height: 1.0, length: cellSize + wallThickness)
                    wall.position = SCNVector3(px - cellSize / 2.0, 0.5, pz)
                    mazeContainerNode.addChildNode(wall)
                }
                if cell.rightWall {
                    let wall = NodeFactory.createWall(width: wallThickness, height: 1.0, length: cellSize + wallThickness)
                    wall.position = SCNVector3(px + cellSize / 2.0, 0.5, pz)
                    mazeContainerNode.addChildNode(wall)
                }
            }
        }
        
        var availableCells: [(Int, Int)] = []
        for x in 0..<maze.width {
            for y in 0..<maze.height {
                // exclude ball A start
                if x == maze.width - 1 && y == 0 { continue }
                // exclude ball C start
                if x == maze.width / 2 && y == maze.height / 2 { continue }
                
                let cell = maze.cells[x][y]
                var wallCount = 0
                if cell.topWall { wallCount += 1 }
                if cell.bottomWall { wallCount += 1 }
                if cell.leftWall { wallCount += 1 }
                if cell.rightWall { wallCount += 1 }
                
                // Only consider dead ends (cells with exactly 3 walls)
                if wallCount == 3 {
                    availableCells.append((x, y))
                }
            }
        }
        availableCells.shuffle()
        
        let targetACell = availableCells.isEmpty ? (0, maze.height - 1) : availableCells.removeFirst()
        let targetCCell = availableCells.isEmpty ? (0, 0) : availableCells.removeFirst()
        
        // Target A: Random Location
        let endAPos = SCNVector3(offsetX + CGFloat(targetACell.0) * cellSize + (cellSize / 2.0), 0.0, offsetZ + CGFloat(targetACell.1) * cellSize + (cellSize / 2.0))
        let targetA = NodeFactory.createTargetZone(categoryBitMask: PhysicsCategory.endA, color: .red, size: cellSize)
        targetA.position = endAPos
        mazeContainerNode.addChildNode(targetA)
        
        // Target C: Random Location
        let endCPos = SCNVector3(offsetX + CGFloat(targetCCell.0) * cellSize + (cellSize / 2.0), 0.0, offsetZ + CGFloat(targetCCell.1) * cellSize + (cellSize / 2.0))
        let targetC = NodeFactory.createTargetZone(categoryBitMask: PhysicsCategory.endC, color: .purple, size: cellSize)
        targetC.position = endCPos
        mazeContainerNode.addChildNode(targetC)
        
        // Place balls safely in the air above their respective start cells
        // Spawning them exactly resting on the ground might still trigger SceneKit's overlapping physics resolution
        let spawnHeight: Float = 0.6
        
        // Ball A starts at (width-1, 0) - Top Right
        ballANode = NodeFactory.createLiquidBall(categoryBitMask: PhysicsCategory.ballA, color: .red)
        let ballA_X = offsetX + CGFloat(maze.width - 1) * cellSize + (cellSize / 2.0)
        let ballA_Z = offsetZ + (cellSize / 2.0)
        ballANode?.position = SCNVector3(Float(ballA_X), spawnHeight, Float(ballA_Z))
        // Zero out any pre-existing velocity on spawn
        ballANode?.physicsBody?.velocity = SCNVector3Zero
        mazeContainerNode.addChildNode(ballANode!)
        
        // Ball C starts at (width/2, height/2) - Middle
        ballCNode = NodeFactory.createLiquidBall(categoryBitMask: PhysicsCategory.ballC, color: .purple)
        let ballC_X = offsetX + CGFloat(maze.width / 2) * cellSize + (cellSize / 2.0)
        let ballC_Z = offsetZ + CGFloat(maze.height / 2) * cellSize + (cellSize / 2.0)
        ballCNode?.position = SCNVector3(Float(ballC_X), spawnHeight, Float(ballC_Z))
        // Zero out any pre-existing velocity on spawn
        ballCNode?.physicsBody?.velocity = SCNVector3Zero
        mazeContainerNode.addChildNode(ballCNode!)
    }
    
    func applyGravity(pitch: Double, roll: Double) {
        let forceMultiplier: Float = 25.0
        let gravityX = Float(roll) * forceMultiplier
        let gravityZ = Float(pitch) * forceMultiplier
        scene.physicsWorld.gravity = SCNVector3(gravityX, -9.8, gravityZ)
    }
    
    // Reset gravity to default standard earth gravity (for AR mode)
    func resetGravity() {
        scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
    }
    
    func updateBallsDamping(viscosity: CGFloat) {
        // viscosity is 0.0 to 1.0 from the slider.
        // If slider is near 0.0 (left): ball A is sluggish (high damping), ball C is slippery (low damping)
        // If slider is near 1.0 (right): ball A is slippery (low damping), ball C is sluggish (high damping)
        
        let dampingA = CGFloat(0.1 + ((1.0 - viscosity) * 0.85))
        let dampingC = CGFloat(0.1 + (viscosity * 0.85))
        
        ballANode?.physicsBody?.damping = dampingA
        ballCNode?.physicsBody?.damping = dampingC
        
        #if canImport(UIKit)
        let colorA = UIColor.red
        let colorC = UIColor.purple
        #else
        let colorA = NSColor.red
        let colorC = NSColor.purple
        #endif
        
        MaterialBuilder.adjustLiquidColor(material: ballANode?.geometry?.firstMaterial, baseColor: colorA, damping: dampingA)
        MaterialBuilder.adjustLiquidColor(material: ballCNode?.geometry?.firstMaterial, baseColor: colorC, damping: dampingC)
    }
    
    // MARK: - GameStateDelegate
    func ballCollidedWithWall() {
        #if canImport(UIKit)
        triggerHapticFeedback(style: .light)
        #endif
    }
    
    func ballReachedTarget(ball: Int) {
        if ball == PhysicsCategory.ballA && !ballAReady {
            ballAReady = true
            #if canImport(UIKit)
            triggerHapticFeedback(style: .medium)
            #endif
        }
        if ball == PhysicsCategory.ballC && !ballCReady {
            ballCReady = true
            #if canImport(UIKit)
            triggerHapticFeedback(style: .medium)
            #endif
        }
        checkWinCondition()
    }
    
    func ballLeftTarget(ball: Int) {
        if ball == PhysicsCategory.ballA { ballAReady = false }
        if ball == PhysicsCategory.ballC { ballCReady = false }
        checkWinCondition()
    }
    
    private func checkWinCondition() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onBallReadyStateChanged?(self.ballAReady, self.ballCReady)
            if self.ballAReady && self.ballCReady {
                if !self.isWinTriggered {
                    self.isWinTriggered = true
                    #if canImport(UIKit)
                    self.triggerHapticFeedback(style: .heavy)
                    #endif
                    self.onWinStateChanged?(true)
                    
                    // Stop balls from moving immediately
                    self.ballANode?.physicsBody?.velocity = SCNVector3Zero
                    self.ballANode?.physicsBody?.angularVelocity = SCNVector4Zero
                    self.ballANode?.physicsBody?.type = .static
                    
                    self.ballCNode?.physicsBody?.velocity = SCNVector3Zero
                    self.ballCNode?.physicsBody?.angularVelocity = SCNVector4Zero
                    self.ballCNode?.physicsBody?.type = .static
                    
                    self.startEmojiRain()
                }
            } else {
                self.isWinTriggered = false
                self.onWinStateChanged?(false)
            }
        }
    }
    
    private var isWinTriggered = false
    
    private func startEmojiRain() {
        let emojis = ["🎉", "✨", "🎊", "🔥", "🌟", "🎈", "🏆", "👏"]
        let spawnHeight: Float = 8.0 // Lower to be in view faster
        let areaRange: Float = 4.0 // Tighter area
        
        emojiSpawnTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let randomEmoji = emojis.randomElement()!
            let emojiNode = NodeFactory.createEmojiNode(emoji: randomEmoji, size: CGFloat.random(in: 0.7...1.5))
            
            let randomX = Float.random(in: -areaRange...areaRange)
            let randomZ = Float.random(in: -areaRange...areaRange)
            
            emojiNode.position = SCNVector3(randomX, spawnHeight, randomZ)
            
            // Random spin
            emojiNode.physicsBody?.applyTorque(SCNVector4(Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: -1...1), Float.random(in: 1...5)), asImpulse: true)
            
            // Force it downwards regardless of phone tilt
            emojiNode.physicsBody?.applyForce(SCNVector3(0, -5, 0), asImpulse: true)
            
            self.scene.rootNode.addChildNode(emojiNode)
            self.emojiNodes.append(emojiNode)
            
            // Limit total emojis to prevent lag
            if self.emojiNodes.count > 150 {
                let old = self.emojiNodes.removeFirst()
                old.removeFromParentNode()
            }
        }
    }
    
    #if canImport(UIKit)
    func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    #else
    func triggerHapticFeedback(style: Int) {
        // Fallback or ignore for macOS
    }
    #endif
}
