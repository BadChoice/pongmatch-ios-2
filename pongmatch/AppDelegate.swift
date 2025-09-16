import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    // Called when APNs has assigned the device a unique token
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Apn.onTokenReceived(deviceToken)
    }

    // Called if APNs registration failed
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error)")
    }
}
