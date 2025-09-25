import Foundation
import UIKit
import RevoHttp
internal import RevoFoundation

class Api {
            
    let client:ApiClient
    
    init(_ token:String){
        self.client = ApiClient(token)
    }
    
    static func makeFromStorageKey() -> Api? {
        guard let token = Storage().get(.apiToken) else {
            return nil
        }
        return Api(token)
    }

    static func login(email:String, password:String, deviceName:String) async throws -> String {
        
        struct TokenResponse : Codable {
            let token:String
        }
        
        let response:TokenResponse = try await ApiClient.call(method: .post, url: "login", params:[
            "email": email,
            "password": password,
            "device_name" : deviceName
        ], headers:[
            "Accept": "application/json"
        ])
        
        return response.token
    }
    
    static func register(name:String, username:String, email:String, password:String, passwordConfirm:String, deviceName:String) async throws -> String {
        
        struct TokenResponse : Codable {
            let token:String
        }
        
        let response:TokenResponse = try await ApiClient.call(method: .post, url: "register", params:[
            "name" : name,
            "username" : username,
            "email": email,
            "password": password,
            "password_confirmation" : passwordConfirm,
            "timezone" : TimeZone.current.identifier,
            //"language" : Locale.current.language.languageCode?.identifier ?? "en",
            "language" : "en",
            "device_name" : deviceName
        ], headers:[
            "Accept": "application/json"
        ])
        
        return response.token
    }
    
    func me() async throws -> User {
        struct UserResponse : Codable {
            var data:User
        }
        do{
            var userResponse:UserResponse = try await client.call(method: .get, url: "me")
            if let details = try? await deepDetails(userResponse.data) {
                userResponse.data.deepDetails = details
            }
            return userResponse.data
        } catch {
            print(error)
            throw error
        }
    }
    
    func registerApnToken(_ token:String) async throws {
        struct Response:Codable {}
        
        do {
            let _:Response = try await client.call(method: .post, url: "me/apnToken", params:[
                "token": token
            ])
        } catch {
            print(error)
            throw error
        }
    }

    
    func updateProfile(name:String, language:Language, timeZone:String, phonePrefix:String?, phone:String?, address:String?, acceptChallengesFrom:AcceptChallengeRequestFrom) async throws  -> User {
        
        struct Response : Codable {
            let data:User
        }
        
        do {
            let response:Response = try await client.call(method: .put, url: "me", params: [
                "name": name,
                "language": language.rawValue,
                "timezone": timeZone,
                "phone_prefix": phonePrefix ?? "",
                "phone": phone ?? "",
                "address": address ?? "",
                "accept_challenges_from": acceptChallengesFrom.rawValue,
            ])
            
            return response.data
            
        } catch {
            print(error)
            throw error
        }
    }
    
    func uploadAvatar(_ image:UIImage) async throws -> User {

        try await withCheckedThrowingContinuation { continuation in
            struct Response : Codable {
                let data:User
            }
            
            let request = MultipartHttpRequest(method: .post, url: Pongmatch.url + "api/me/avatar", headers: client.headers)
            let _ = request.addMultipart(paramName: "avatar", fileName: "avatar.jpg", image: image.resized(to: CGSize(width: 256, height: 256)))
            
            Http().callMultipart(request) { response in
                do {
                    let result:Response = try ApiClient.parseResponse(response)
                    return continuation.resume(returning: result.data)
                }catch{
                    print(error)
                    continuation.resume(throwing: error)
                }
            }
        }
    
    }
    
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
    
    func users(search text:String?) async throws -> [User] {
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
    
    func games() async throws -> [Game] {
        struct GamesResponse : Codable {
            let data:[Game]
        }
        
        do {
            let gamesResponse:GamesResponse = try await client.call(method: .get, url: "games/finished")
            return gamesResponse.data.unique(\.id)
        } catch {
            print(error)
            throw error
        }
    }
    
    func store(game:Game) async throws -> Game {
        struct GameResponse : Codable {
            let data:Game
        }
            
        do {
            let gameResponse:GameResponse = try await client.call(method: .post, url: "games", params:[
                "date" : game.date.toISOString,
                "information" : game.information,
                "status" : game.status.rawValue,
                "winning_condition" : game.winning_condition.rawValue,
                "ranking_type" : game.ranking_type.rawValue,
                "initial_score" : InitialScore.standard.rawValue, //TODO
                "player1_id" : game.player1.id,
                "player2_id" : game.player2.id,
            ])
            return gameResponse.data
            
        } catch {
            print(error)
            throw error
        }
    }
    
    func uploadResults(_ game:Game, results:[[Int]]? = nil) async throws -> Game {
        
        guard !game.needsId else {
            throw ApiClient.Errors.other("Game ID is nil")
        }
        
        let resultsToUpload = results ?? game.results
        
        guard let resultsToUpload, resultsToUpload.count > 0 else {
            throw ApiClient.Errors.other("No results to upload")
        }
        
        struct GameResponse : Codable {
            let data:Game
        }
        
        struct ResultsRequest: Codable {
            let results: [[Int]]
        }
        
        do {
            let gameResponse:GameResponse = try await client.call(method: .post, url: "games/\(game.id)/results", json:ResultsRequest(
                results: resultsToUpload
            ))
            return gameResponse.data
            
        } catch {
            print(error)
            throw error
        }
    }
    
    func acceptChallenge(_ game:Game) async throws -> Game {
        guard !game.needsId else {
            throw ApiClient.Errors.other("Game ID is nil")
        }
        
        struct Response : Codable {
            let data:Game
        }
        
        do{
            let response:Response = try await client.call(method: .post, url: "games/\(game.id)/accept")
            return response.data
        } catch {
            print(error)
            throw error
        }
    }
    
    func declineChallenge(_ game:Game) async throws -> Game {
        guard !game.needsId else {
            throw ApiClient.Errors.other("Game ID is nil")
        }
        
        struct Response : Codable {
            let data:Game
        }
        
        do{
            let response:Response = try await client.call(method: .post, url: "games/\(game.id)/decline")
            return response.data
        } catch {
            print(error)
            throw error
        }
    }
    
    func getGame(publicScoreboardCode:String) async throws -> Game {        
        struct Response : Codable {
            let data:Game
        }
        
        do{
            let response:Response = try await client.call(method: .get, url: "games/\(publicScoreboardCode)")
            return response.data
        } catch {
            print(error)
            throw error
        }
    }
    
    func getPublicScoreboardCode(_ game:Game) async throws -> String {
        guard !game.needsId else {
            throw ApiClient.Errors.other("Game ID is nil")
        }
        
        struct Response : Codable {
            let code:String
        }
        
        do{
            let response:Response = try await client.call(method: .get, url: "games/\(game.id)/publicScoreboardCode")
            return response.code
        } catch {
            print(error)
            throw error
        }
    }
    
    struct PlayerDetails : Codable {
        let resulting_points:Int?
        let earned_points:Int?
    }
    
    func playersDetails(game:Game) async throws -> (player1:PlayerDetails?, player2:PlayerDetails?) {
        guard !game.needsId else {
            throw ApiClient.Errors.other("Game ID is nil")
        }
        
        struct Response : Codable {
            let player1:PlayerDetails?
            let player2:PlayerDetails?
        }
        
        do{
            let response:Response = try await client.call(method: .get, url: "games/\(game.id)/playersDetails")
            return (response.player1, response.player2)
        } catch {
            print(error)
            throw error
        }
    }
    
    func delete(game:Game) async throws {
        guard !game.needsId else {
            throw ApiClient.Errors.other("Game ID is nil")
        }
        
        struct Response : Codable {
        }
        
        do{
            let _:Response = try await client.call(method: .delete, url: "games/\(game.id)")
        } catch {
            print(error)
            throw error
        }
    }
    
    func sendFeedback(_ message:String) async throws {
        struct Response : Codable { }
        
        do{
            let _ :Response = try await client.call(method: .post, url: "feedback", params:[
                "message" : message
            ])
            return
        } catch {
            print(error)
            throw error
        }
    }
    
}
