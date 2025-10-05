enum LeagueStatus : String, Codable, CustomStringConvertible
{
    case draft   //When creating a match without an opponent
    case upcoming //When creating a match with opponent, but he needs to accept it
    case started //When challenge accepted
    case finished //When playing
    case canceled //If the game is cancel·led

    var description: String {
        switch self {
        case .draft: "Draft"
        case .upcoming: "Upcoming"
        case .started: "Started"
        case .finished: "Finished"
        case .canceled: "Canceled"
        }
    }
    
    var icon:String {
        switch self {
        case .draft: "pencil"
        case .upcoming: "calendar"
        case .started: "play.fill"
        case .finished: "flag.pattern.checkered"
        case .canceled: "xmark.circle"
        }
    }
}
