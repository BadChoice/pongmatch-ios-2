import Foundation

struct FlicAssignment : Codable {
    var player1:String?
    var player2:String?
    
    static func get() -> FlicAssignment {
        guard let data = Storage().defaults.data(forKey: Storage.Keys.flicButtonsAssignments.rawValue) else {
            return FlicAssignment(player1: nil, player2: nil)
        }
        return (try? JSONDecoder().decode(FlicAssignment.self, from: data)) ?? FlicAssignment(player1: nil, player2: nil)
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        Storage().defaults.set(data, forKey: Storage.Keys.flicButtonsAssignments.rawValue)
    }
}
