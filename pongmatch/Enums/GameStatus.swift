enum GameStatus : String, Codable, CustomStringConvertible {
    case needsOpponent    = "needsOpponent"   //When creating a match without an opponent
    case waitingOpponent  = "waitingOpponent" //When creating a match with opponent, but he needs to accept it
    case planned          = "planned" //When challenge accepted
    case ongoing          = "ongoing" //When playing
    case finished         = "finished" //When finished
    case canceled         = "canceled" //If the game is cancel·led
    case opponentDeclined = "opponentDeclined" //IF the opponent declines
    
    var description: String {
        switch self {
        case .needsOpponent: "Needs Oponent"
        case .waitingOpponent: "Waiting for Oponent"
        case .planned: "Planned"
        case .ongoing: "Ongoing"
        case .finished: "Finished"
        case .canceled: "Canceled"
        case .opponentDeclined: "Opponent Declined"
        }
    }
    
    var icon: String {
        switch self {
        case .needsOpponent: "person.crop.circle.dashed"
        case .waitingOpponent: "person.badge.clock"
        case .planned: "calendar"
        case .ongoing: "play.fill"
        case .finished: "flag.pattern.checkered"
        case .canceled: "xmark.circle"
        case .opponentDeclined: "person.slash.fill"
        }
    }
}
