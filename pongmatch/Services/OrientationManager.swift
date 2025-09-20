import UIKit

final class OrientationManager {
    static let shared = OrientationManager()
    private init() {}

    var supportedOrientations: UIInterfaceOrientationMask = .portrait

    func set(_ mask: UIInterfaceOrientationMask) {
        supportedOrientations = mask
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { error in
                print("Failed to update orientation: \(error)")
            }
        }
        // Force UIKit to re-query supported orientations
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
}
