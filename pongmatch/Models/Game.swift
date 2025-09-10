import Foundation

struct Game : Codable {
    let id:Int
    
    //initial_score
    let ranking_type:RankingType
    let winning_condition:WinningCondition
    
    let information:String?
    let date:Date
    let status:GameStatus
    let results:[[String]]?
    //let created_at:Date
    //let updated_at:Date?
}
