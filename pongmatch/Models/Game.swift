import Foundation

enum GameStatus : String, Codable {
    case needsOpponent    = "needsOpponent"   //When creating a match without an opponent
    case waitingOpponent  = "waitingOpponent" //When creating a match with opponent, but he needs to accept it
    case planned          = "planned" //When challenge accepted
    case ongoing          = "ongoing" //When playing
    case finished         = "finished" //When finished
    case canceled         = "canceled" //If the game is cancel·led
    case opponentDeclined = "opponentDeclined" //IF the opponent declines
}

struct Game : Codable {
    let id:Int
    
    //initial_score
    //ranking_type
    //winning_condition
    
    let information:String?
    let date:Date
    let status:GameStatus
    let created_at:Date
    let updated_at:Date?
}
