import SwiftUI

struct ForceOrientation: ViewModifier {
    let orientation: UIInterfaceOrientationMask
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                //DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    OrientationManager.shared.set(orientation)
                //}
            }
            .onDisappear(){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    OrientationManager.shared.set(.portrait)
                }
            }
    }
}

extension View {
    func forceOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
        modifier(ForceOrientation(orientation: orientation))
    }
}
