import Foundation

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
