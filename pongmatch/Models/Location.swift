import Foundation

struct Coordinates: Codable {
    let latitude:Double
    let longitude:Double
}

struct Location : Codable {
    let id:Int
    let user_id:Int?
    let name:String
    let isIndoor:Bool
    let coordinates:Coordinates
    
    let photo:String?
    let description:String?
    let instructions:String?
    let isPrivate:Bool?
    let number_of_tables:Int?
    let address:String?    
    let created_at:Date?
    let updated_at:Date?
}
