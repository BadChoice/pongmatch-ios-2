import SwiftUI

// MARK: - Shake Effect
private struct ShakeGeometryEffect: GeometryEffect {
    var amplitude: CGFloat
    var axis: Axis
    var phase: CGFloat
    
    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let translation = amplitude * sin(phase * 2 * .pi)
        switch axis {
        case .horizontal:
            return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
        case .vertical:
            return ProjectionTransform(CGAffineTransform(translationX: 0, y: translation))
        }
    }
}


struct ShakeEffect: ViewModifier {
    let intensity: CGFloat        // how far to move in points
    let speed: Double             // cycles per second
    let axis: Axis
    
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .modifier(ShakeGeometryEffect(amplitude: intensity, axis: axis, phase: phase))
            .onAppear {
                // Drive a continuous phase from 0 -> 1, repeating forever
                withAnimation(.linear(duration: 1 / max(speed, 0.0001)).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shake(intensity: CGFloat, speed: Double = 2, axis: Axis = .horizontal) -> some View {
        modifier(ShakeEffect(intensity: intensity, speed: speed, axis: axis))
    }
}

#Preview {
    Text("Shake Me")
        .shake(intensity: 2, speed: 4, axis: .horizontal)
        .shake(intensity: 2, speed: 5, axis: .vertical)
        
}
