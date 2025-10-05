import UIKit

struct Apn {
    static func refreshPushToken() {
        
        guard !Storage().get(.apnTokenSaved) else {
            return //already saved
        }
            
        if let token:String = Storage().get(.apnToken){
            return saveToken(token)
        }
        
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
    
    static func onTokenReceived(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { String(format: "%02x", $0) }
        let token = tokenParts.joined()
        print("APNs device token: \(token)")
        Storage().save(.apnToken, value: token)
        
        saveToken(token)
    }
    
    private static func saveToken(_ token:String) {
        Task {
            do {
                try await Api.makeFromStorageKey()?.me.registerApnToken(token)
                Storage().save(.apnTokenSaved, value: true)
            } catch {
                
            }
        }
    }
}
