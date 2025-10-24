import Foundation

enum FlicAssignmentMode : String, Codable {
    case courtSide
    case player
}

struct FlicAssignment : Codable {
    var mode:FlicAssignmentMode
    var player1:String?
    var player2:String?
    
    func display(for player:Player) -> String {
        if player == .player1 {
            return mode == .courtSide ? "Left side" : "Player 1"
        }
        return mode == .courtSide ? "Right side" : "Player 2"
    }
    
    func icon(for player:Player) -> String {
        if player == .player1 {
            return mode == .courtSide ? "square.lefthalf.filled" : "1.circle"
        }
        return mode == .courtSide ? "square.lefthalf.filled" : "2.circle"
    }
    
    static func get() -> FlicAssignment {
        guard let data = Storage().defaults.data(forKey: Storage.Keys.flicButtonsAssignments.rawValue) else {
            return FlicAssignment(mode:.courtSide, player1: nil, player2: nil)
        }
        return (try? JSONDecoder().decode(FlicAssignment.self, from: data)) ?? FlicAssignment(mode:.courtSide, player1: nil, player2: nil)
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(self) else { return }
        Storage().defaults.set(data, forKey: Storage.Keys.flicButtonsAssignments.rawValue)
    }
}
