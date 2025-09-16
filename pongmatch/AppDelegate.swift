import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02x", $0) }
        let token = tokenParts.joined()
        print("APNs device token: \(token)")
        
        Task {
            try? await Api.makeFromStorageKey()?.registerApnToken(token)
        }
    }

    // Called if APNs registration failed
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error)")
    }
}
