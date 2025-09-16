import UIKit

struct Apn {
    static func refreshPushToken() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                // Already authorized — just re-register
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            case .denied:
                print("Notifications are denied — direct user to Settings if needed.")
            case .notDetermined:
                // First time — ask for permission
                requestPushNotifications()
            @unknown default:
                break
            }
        }
    }
    
    static func requestPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                } else {
                    print("User denied notifications: \(error?.localizedDescription ?? "No error")")
                }
            }
    }
}
