import Foundation

class Storage {
    
    enum Keys:String {
        case apiToken = "api_token"
        case apnToken = "apn_token"
        case apnTokenSaved = "apn_token_saved"
        case gamesFinishedOnWatch = "gamesFinishedOnWatch"
        case flicButtonsAssignments = "flic_buttons_assignments"
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
    
    func get(_ key:Keys) -> String? {
        defaults.string(forKey: key.rawValue)
    }
    
    func get(_ key:Keys) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }

    func saveGames(_ key:Keys, games:[Game]){
        guard let data = try? JSONEncoder().encode(games) else { return }
        defaults.set(data, forKey: key.rawValue)
    }
    
    func getGames(_ key:Keys) -> [Game] {
        guard let data = defaults.data(forKey: key.rawValue) else { return [] }
        return (try? JSONDecoder().decode([Game].self, from: data)) ?? []
    }
    
}
