internal import RevoFoundation
import RevoHttp

extension Api {
    class Users {
        let client:ApiClient
        
        init(client:ApiClient){
            self.client = client
        }
        
        //MARK: Users and Friends
        func deepDetails(_ user:User) async throws -> UserDeepDetails {
            do {
                let userResponse:UserDeepDetails = try await client.call(method: .get, url: "users/\(user.id)/deepDetails")
                return userResponse
            } catch {
                print(error)
                throw error
            }
        }
        
        func eloHistory(_ user:User) async throws -> [Elo] {
            
            struct Response : Codable {
                let elo_history:[Elo]
            }
            do{
                let userResponse:Response = try await client.call(method: .get, url: "users/\(user.id)/eloHistory")
                return userResponse.elo_history
            } catch {
                print(error)
                throw error
            }
        }
        
        func friend(_ id:Int) async throws -> User {
            struct UserResponse : Codable {
                let data:User
            }
            do{
                let userResponse:UserResponse = try await client.call(method: .get, url: "friend/\(id)")
                return userResponse.data
            } catch {
                print(error)
                throw error
            }
        }
        
        func friendGames(_ id:Int) async throws -> [Game] {
            struct GamesResponse : Codable {
                let data:[Game]
            }
            
            do {
                let gamesResponse:GamesResponse = try await client.call(method: .get, url: "friends/\(id)/games")
                return gamesResponse.data.unique(\.id)
            } catch {
                print(error)
                throw error
            }
        }
        
        struct OneVsOne : Codable {
            let won:Int
            let lost:Int
            let games:[Game]
        }
        
        func friendOneVsOne(_ id:Int) async throws -> OneVsOne {
            struct GamesResponse : Codable {
                let won:Int
                let lost:Int
                let games:[Game]
            }
            
            do {
                return try await client.call(method: .get, url: "friends/\(id)/oneVsOne")
            } catch {
                print(error)
                throw error
            }
        }
        
        func friends() async throws -> [User] {
            
            struct FriendsResponse : Codable {
                let data:[User]
            }
            
            do {
                let userResponse:FriendsResponse = try await client.call(method: .get, url: "friends")
                return userResponse.data.unique(\.id)
            } catch {
                print(error)
                throw error
            }
        }
        
        func follow(_ user:User) async throws {
            struct Response:Codable {}
            
            do {
                let _:Response = try await client.call(method: .post, url: "friends/\(user.id)")
            } catch {
                print(error)
                throw error
            }
        }
        
        func unfollow(_ user:User) async throws {
            struct Response:Codable {}
            
            do {
                let _:Response = try await client.call(method: .delete, url: "friends/\(user.id)")
            } catch {
                print(error)
                throw error
            }
        }
        
        func friendShipStatus(_ user:User) async throws -> FriendshipStatus {
            do {
                return try await client.call(method: .get, url: "friends/\(user.id)/friendship")
            } catch {
                print(error)
                throw error
            }
        }
        
        
        func friends(search text:String?) async throws -> [User] {
            guard let text, !text.isEmpty else { return[] }
            
            struct FriendsResponse : Codable {
                let data:[User]
            }
            
            do {
                let userResponse:FriendsResponse = try await client.call(method: .get, url: "friends/search/\(text)")
                return userResponse.data.unique(\.id)
            } catch {
                print(error)
                throw error
            }
        }
        
        func search(_ text:String?) async throws -> [User] {
            guard let text, !text.isEmpty else { return[] }
            
            struct UsersResponse : Codable {
                let data:[User]
            }
            
            do {
                let userResponse:UsersResponse = try await client.call(method: .get, url: "users/search/\(text)")
                return userResponse.data.unique(\.id)
            } catch {
                print(error)
                throw error
            }
        }
    }    
}
