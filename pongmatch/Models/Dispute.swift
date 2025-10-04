import Foundation

enum DisputeStatus : Codable {
    case open, resolved, rejected
}

struct Dispute : Codable {
    let id:Int
    let reason:String
    let game_id:Int
    let user_id:Int
    //let status:DisputeStatus
    let created_at:Date
}
