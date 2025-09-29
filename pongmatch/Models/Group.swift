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
    
    static func fake() -> PMGroup {
        PMGroup(
            id: 1,
            name: "Pongmatch",
            description: "Description of the group",
            token: "ABCDEFG",
            photo: "https://static.wixstatic.com/media/d9a908_9788d245789c4c4b92b72651bf14f704~mv2.jpg/v1/fill/w_752,h_502,al_c,q_85,usm_0.66_1.00_0.01,enc_avif,quality_auto/d9a908_9788d245789c4c4b92b72651bf14f704~mv2.jpg",
            isPrivate: false,
            usersCount: 42,
            created_at: Date(),
            user: UserGroup(isAdmin: true, status: .active)
        )
    }
}
