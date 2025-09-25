import Foundation

class IPhoneSync : WatchUserInfoDelegate {
    
    init () {
        WatchManager.shared.userInfoDelegate = self
    }
    
    func onUserInfoReceived(userInfo: [String : Any]) {
        guard let data = userInfo["auth_user"] as? Data else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: "auth_user")
    }
    
    
    static func authUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: "auth_user") else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }
    
}
