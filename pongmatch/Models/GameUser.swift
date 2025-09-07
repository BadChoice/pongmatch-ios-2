import Foundation

struct GameUser: Codable {
    let game_id:Int
    let user_id:Int
    let winner:Bool?
    let earnedPoints:Int?
    let resultingPoints:Int?
    let created_at:Date
    let updated_at:Date?
}
