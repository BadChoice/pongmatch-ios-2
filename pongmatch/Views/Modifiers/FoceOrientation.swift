import SwiftUI

struct ForceOrientation: ViewModifier {
    let orientation: UIInterfaceOrientationMask
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                setOrientation(orientation)
            }
            .onDisappear {
                // restore to portrait when leaving
                setOrientation(.portrait)
            }
    }
    
    private func setOrientation(_ mask: UIInterfaceOrientationMask) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { error in
            /*if let error {
                print("Failed to update orientation: \(error)")
            }*/
        }
    }
}

extension View {
    func forceOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
        self.modifier(ForceOrientation(orientation: orientation))
    }
}
