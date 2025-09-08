enum GameStatus : String, Codable {
    case needsOpponent    = "needsOpponent"   //When creating a match without an opponent
    case waitingOpponent  = "waitingOpponent" //When creating a match with opponent, but he needs to accept it
    case planned          = "planned" //When challenge accepted
    case ongoing          = "ongoing" //When playing
    case finished         = "finished" //When finished
    case canceled         = "canceled" //If the game is cancel·led
    case opponentDeclined = "opponentDeclined" //IF the opponent declines
}
