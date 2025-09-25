import Foundation

class Storage {
    
    enum Keys:String {
        case apiToken = "api_token"
        case apnToken = "apn_token"
        case apnTokenSaved = "apn_token_saved"
        case gamesFinishedOnWatch = "gamesFinishedOnWatch"
    }
    
    let defaults:UserDefaults
    
    init(_ defaults:UserDefaults = UserDefaults.standard){
        self.defaults = defaults
    }
    
    func save(_ key:Keys, value:String?) {
        defaults.set(value, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    func save(_ key:Keys, value:Bool) {
        defaults.set(value, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    func get(_ key:Keys) -> String? {
        defaults.string(forKey: key.rawValue)
    }
    
    func get(_ key:Keys) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }

    
}
