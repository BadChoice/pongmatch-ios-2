import Foundation

class Storage {
    
    enum Keys:String {
        case apiToken = "api_token"
    }
    
    let defaults:UserDefaults
    
    init(_ defaults:UserDefaults = UserDefaults.standard){
        self.defaults = defaults
    }
    
    func save(_ key:Keys, value:String?) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func get(_ key:Keys) -> String? {
        defaults.string(forKey: key.rawValue)
    }
    
    
}
