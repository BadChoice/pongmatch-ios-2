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
    }
    
    func save(_ key:Keys, value:Bool) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    func save<T:Codable>(_ key:Keys, value:T){
        guard let toSave = try? JSONEncoder().encode(value) else { return }
        defaults.set(toSave, forKey: key.rawValue)
    }
    
    func get(_ key:Keys) -> String? {
        defaults.string(forKey: key.rawValue)
    }
    
    func get(_ key:Keys) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }
    
    func get<T:Codable>(_ key:Keys) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    
}
