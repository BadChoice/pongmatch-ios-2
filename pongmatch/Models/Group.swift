import Foundation

struct UserGroup :Codable {
    let isAdmin:Bool
    let status:JoinStatus
}

struct PMGroup : Codable {
    let id:Int
    let name:String
    let description:String?
    let token:String?
    let photo:String?
    let isPrivate:Bool
    let usersCount:Int
    let created_at:Date
    let user:UserGroup
}
