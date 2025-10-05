import SwiftUI
import CoreMotion

struct MotionGestureModifier: ViewModifier {
    @State private var motionManager = CMMotionManager()
    @State private var lastShakeTime = Date.distantPast
    @State private var gestureCount = 0
    
    let onGesture: (Int) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                startMotionUpdates()
            }
            .onDisappear {
                motionManager.stopDeviceMotionUpdates()
            }
    }
    
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.05 // 20 Hz
        motionManager.startDeviceMotionUpdates(to: .main) { data, error in
            guard let motion = data else { return }
            
            // Acceleració de l'usuari (sense gravetat)
            let acc = motion.userAcceleration
            let accMagnitude = sqrt(acc.x * acc.x + acc.y * acc.y + acc.z * acc.z)
            
            // Rotació del canell
            let rotation = motion.rotationRate
            let rotationMagnitude = sqrt(rotation.x * rotation.x + rotation.y * rotation.y + rotation.z * rotation.z)
            
            // Thresholds (ajusta segons proves)
            if accMagnitude > 1.5 && rotationMagnitude < 5.0 {
                let now = Date()
                
                // Reinici comptador si fa molt temps des del darrer gest
                if now.timeIntervalSince(lastShakeTime) > 1.5 {
                    gestureCount = 0
                }
                
                gestureCount += 1
                lastShakeTime = now
                
                onGesture(gestureCount)
                
                if gestureCount >= 3 {
                    gestureCount = 0 // reiniciem després de 3
                }
            }
        }
    }
}

extension View {
    func motionGestures(onGesture: @escaping (Int) -> Void) -> some View {
        self.modifier(MotionGestureModifier(onGesture: onGesture))
    }
}

/*import SwiftUI
import CoreMotion

struct MotionGestureModifier: ViewModifier {
    @State private var motionManager = CMMotionManager()
    @State private var lastShakeTime = Date.distantPast
    @State private var gestureCount = 0
    
    let onGesture: (Int) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                startMotionUpdates()
            }
            .onDisappear {
                motionManager.stopAccelerometerUpdates()
            }
    }
    
    private func startMotionUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            guard let accel = data?.acceleration else { return }
            
            let magnitude = sqrt(accel.x * accel.x + accel.y * accel.y + accel.z * accel.z)
            
            if magnitude > 2.5 { // <- ajusta llindar segons proves
                let now = Date()
                
                if now.timeIntervalSince(lastShakeTime) > 1.5 {
                    gestureCount = 0
                }
                
                gestureCount += 1
                lastShakeTime = now
                
                onGesture(gestureCount)
                
                if gestureCount >= 3 {
                    gestureCount = 0 // reiniciem després de 3
                }
            }
        }
    }
}

extension View {
    func motionGestures(onGesture: @escaping (Int) -> Void) -> some View {
        self.modifier(MotionGestureModifier(onGesture: onGesture))
    }
}
*/
