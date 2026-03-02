import Foundation
import CoreMotion

class MotionInputManager: ObservableObject {
    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    
    #if os(iOS)
    private let motionManager = CMMotionManager()
    
    func start() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
                guard let data = data else { return }
                
                // Assuming standard screen orientation
                self?.pitch = data.attitude.pitch
                self?.roll = data.attitude.roll
            }
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
    #else
    // Fallback or empty implementation for macOS
    func start() { }
    func stop() { }
    #endif
}
