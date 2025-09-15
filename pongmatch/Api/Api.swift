import Foundation
import UIKit
import RevoHttp

internal import RevoFoundation

class Api {
    
    enum Errors : Error, CustomStringConvertible {
        case not200(_ status:Int, _ error:ErrorResponse? = nil)
        case notAuthorized
        case forbidden
        case notFound
        case unprocessableContent(_ error:ErrorResponse?)
        
        case cantDecodeResponse
        case emptyResponse
        case errorResponse(_ error:ErrorResponse?)
        case other(_ error:String)
        
        var description: String {
            switch self {
            case .not200(let status, let error): error?.message ?? "Can't process the request. \(status)"
            case .notAuthorized: "Not authorized."
            case .forbidden: "Forbidden."
            case .notFound: "Not found."
            case .unprocessableContent(let error): error?.message ?? "Unprocessable content."
            case .cantDecodeResponse: "Unexpected server response."
            case .emptyResponse: "No data received from server."
            case .errorResponse(let error): error?.message  ?? "Can't process the request."
            case .other(let error): "Other response \(error)"
            }
        }
    }
    
    struct ErrorResponse : Codable {
        let message:String
        let errors:[String:[String]]?
    }

    
    let token:String
    
    init(_ token:String){
        self.token = token
    }

    static func login(email:String, password:String, deviceName:String) async throws -> String {
        
        struct TokenResponse : Codable {
            let token:String
        }
        
        let response:TokenResponse = try await Self.call(method: .post, url: "login", params:[
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
        
        let response:TokenResponse = try await Self.call(method: .post, url: "register", params:[
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
            var userResponse:UserResponse = try await Self.call(method: .get, url: "me", headers: headers)
            if let ranking = try? await globalRankingPosition(userResponse.data) {
                userResponse.data.global_ranking = ranking
            }
            return userResponse.data
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
            let response:Response = try await Self.call(method: .put, url: "me", params: [
                "name": name,
                "language": language.rawValue,
                "timezone": timeZone,
                "phone_prefix": phonePrefix ?? "",
                "phone": phone ?? "",
                "address": address ?? "",
                "accept_challenges_from": acceptChallengesFrom.rawValue,
            ], headers: headers)
            
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
            
            let request = MultipartHttpRequest(method: .post, url: Pongmatch.url + "api/me/avatar", headers: headers)
            let _ = request.addMultipart(paramName: "avatar", fileName: "avatar.jpg", image: image.resized(to: CGSize(width: 256, height: 256)))
            
            Http().callMultipart(request) { response in
                do {
                    let result:Response = try Self.parseResponse(response)
                    return continuation.resume(returning: result.data)
                }catch{
                    print(error)
                    continuation.resume(throwing: error)
                }
            }
        }
    
    }
    
    func globalRankingPosition(_ user:User) async throws -> Int {
        struct Response : Codable {
            let global_ranking:Int
        }
        do {
            let userResponse:Response = try await Self.call(method: .get, url: "users/\(user.id)/globalRankingPosition", headers: headers)
            return userResponse.global_ranking
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
            let userResponse:Response = try await Self.call(method: .get, url: "users/\(user.id)/eloHistory", headers: headers)
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
            let userResponse:UserResponse = try await Self.call(method: .get, url: "friend/\(id)", headers: headers)
            return userResponse.data
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
            let userResponse:FriendsResponse = try await Self.call(method: .get, url: "friends", headers: headers)
            return userResponse.data.unique(\.id)
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
            let userResponse:FriendsResponse = try await Self.call(method: .get, url: "friends/search/\(text)", headers: headers)
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
            let gamesResponse:GamesResponse = try await Self.call(method: .get, url: "games/finished", headers: headers)
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
            let gameResponse:GameResponse = try await Self.call(method: .post, url: "games", params:[
                "date" : game.date.toISOString,
                "information" : game.information,
                "status" : game.status.rawValue,
                "winning_condition" : game.winning_condition.rawValue,
                "ranking_type" : game.ranking_type.rawValue,
                "initial_score" : InitialScore.standard.rawValue, //TODO
                "player1_id" : game.player1.id,
                "player2_id" : game.player2.id,
            ], headers: headers)
            return gameResponse.data
            
        } catch {
            print(error)
            throw error
        }
    }
    
    func uploadResults(_ game:Game, results:[[Int]]? = nil) async throws -> Game {
        
        guard let id = game.id else {
            throw Errors.other("Game ID is nil")
        }
        
        let resultsToUpload = results ?? game.results
        
        guard let resultsToUpload, resultsToUpload.count > 0 else {
            throw Errors.other("No results to upload")
        }
        
        struct GameResponse : Codable {
            let data:Game
        }
        
        struct ResultsRequest: Codable {
            let results: [[Int]]
        }
        
        do {
            let gameResponse:GameResponse = try await Self.call(method: .post, url: "games/\(id)/results", json:ResultsRequest(
                results: resultsToUpload
            ), headers: headers)
            return gameResponse.data
            
        } catch {
            print(error)
            throw error
        }
    }
    
    func acceptChallenge(_ game:Game) async throws -> Game {
        guard let id = game.id else {
            throw Errors.other("Game ID is nil")
        }
        
        struct Response : Codable {
            let data:Game
        }
        
        do{
            let response:Response = try await Self.call(method: .post, url: "games/\(id)/accept", headers: headers)
            return response.data
        } catch {
            print(error)
            throw error
        }
    }
    
    func declineChallenge(_ game:Game) async throws -> Game {
        guard let id = game.id else {
            throw Errors.other("Game ID is nil")
        }
        
        struct Response : Codable {
            let data:Game
        }
        
        do{
            let response:Response = try await Self.call(method: .post, url: "games/\(id)/decline", headers: headers)
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
            let response:Response = try await Self.call(method: .get, url: "games/\(publicScoreboardCode)", headers: headers)
            return response.data
        } catch {
            print(error)
            throw error
        }
    }
    
    func getPublicScoreboardCode(_ game:Game) async throws -> String {
        guard let id = game.id else {
            throw Errors.other("Game ID is nil")
        }
        
        struct Response : Codable {
            let code:String
        }
        
        do{
            let response:Response = try await Self.call(method: .get, url: "games/\(id)/publicScoreboardCode", headers: headers)
            return response.code
        } catch {
            print(error)
            throw error
        }
    }
    
    func sendFeedback(_ message:String) async throws {
        struct Response : Codable { }
        
        do{
            let _ :Response = try await Self.call(method: .post, url: "feedback", params:[
                "message" : message
            ], headers: headers)
            return
        } catch {
            print(error)
            throw error
        }
    }
    
    
    // MARK: ------- API Helpers Itself
    private var headers:[String:String] {
        [
            "Authorization" : "Bearer \(token)",
            "Accept": "application/json",
        ]
    }
    
    private static func call<T:Decodable>(method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async throws -> T {
                
        try await withCheckedThrowingContinuation { continuation in
            print("Calling API: \(method) \(url) \(params)")
                        
            Http.call(method, url:Pongmatch.url + "api/" + url, params: params, headers:headers) { response in
                do {
                    continuation.resume(returning: try parseResponse(response))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private static func call<T:Codable,Z:Encodable>(method:HttpRequest.Method, url:String, json:Z, headers:[String:String] = [:]) async throws -> T {
        try print("Calling API: \(method) \(url) \(json.jsonString())")
        
        let finalHeaders = headers.merging(["Content-Type": "application/json"]) { _, new in new }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) -> Void in
            Http.call(method, Pongmatch.url + "api/" + url, json: json, headers:finalHeaders) { response in
                do {
                    continuation.resume(returning: try parseResponse(response))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private static func parseResponse<T:Decodable>(_ response:HttpResponse) throws -> T {
        print("API Response: " + response.toString)
        
        var errorResponse: ErrorResponse? = nil
        if let data = response.data {
            errorResponse = try? jsonDecoder().decode(ErrorResponse.self, from: data)
        }
        
        guard response.statusCode >= 200 && response.statusCode < 300 else {
            if response.statusCode == 401 { throw Errors.notAuthorized }
            if response.statusCode == 403 { throw Errors.forbidden }
            if response.statusCode == 404 { throw Errors.notFound }
            if response.statusCode == 422 { throw Errors.unprocessableContent(errorResponse) }
            throw Errors.not200(response.statusCode, errorResponse)
        }
        
        guard let data = response.data else {
            throw Errors.emptyResponse
        }
        
        do {
            let response = try jsonDecoder().decode(T.self, from: data)
            return response
        } catch {
            print("API Error: \(error)")
            throw Errors.errorResponse(errorResponse)
        }
    }
    
    private static func jsonDecoder() -> JSONDecoder{
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // For ISO 8601 format
        return decoder
    }
}
