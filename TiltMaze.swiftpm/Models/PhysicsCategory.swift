import Foundation

struct PhysicsCategory {
    static let none: Int      = 0
    static let ballA: Int     = 1 << 0
    static let wall: Int      = 1 << 1
    static let endA: Int      = 1 << 2
    static let floor: Int     = 1 << 3
    static let ballC: Int     = 1 << 4
    static let endC: Int      = 1 << 5
}
