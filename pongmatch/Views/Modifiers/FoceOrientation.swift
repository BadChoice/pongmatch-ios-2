import SwiftUI

struct ForceOrientation: ViewModifier {
    let orientation: UIInterfaceOrientationMask
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                OrientationManager.shared.set(orientation)
            }
            .onDisappear {
                OrientationManager.shared.set(.portrait)
            }
    }
}

extension View {
    func forceOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
        modifier(ForceOrientation(orientation: orientation))
    }
}
