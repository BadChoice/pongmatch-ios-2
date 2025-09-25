import Foundation

struct SharedStorage {
            
    enum Keys:String {
        case auth = "auth"
    }
    
    var defaults:UserDefaults?{
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: Pongmatch.sharedStorageGroupId) {
            print("Container path: \(containerURL.path)")
        }
        
        return UserDefaults(suiteName: Pongmatch.sharedStorageGroupId)
    }
    
    func saveAuth(_ user:User){
        guard let defaults else { return }
        guard let data = try? JSONEncoder().encode(user) else { return }
        defaults.set(data, forKey: Keys.auth.rawValue)
    }
    
    func getAuth() -> User? {
        guard let defaults else { return nil }
        guard let data = defaults.data(forKey: Keys.auth.rawValue) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }
}


