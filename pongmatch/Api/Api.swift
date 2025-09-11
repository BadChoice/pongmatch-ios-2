import Foundation
import RevoHttp
internal import RevoFoundation

class Api {
    
    enum Errors : Error, CustomStringConvertible {
        case not200(_ status:Int)
        case notAuthorized
        case forbidden
        case notFound
        
        case cantDecodeResponse
        case emptyResponse
        case errorResponse(_ error:ErrorResponse)
        case other(_ error:String)
        
        var description: String {
            switch self {
            case .not200(let status): "Invalid credentials or server error. \(status)"
            case .notAuthorized: "Not authorized."
            case .forbidden: "Forbidden."
            case .notFound: "Not found."
            case .cantDecodeResponse: "Unexpected server response."
            case .emptyResponse: "No data received from server."
            case .errorResponse(let error): "Error response \(error.message)"
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
    
    func me() async throws -> User {
        struct UserResponse : Codable {
            let data:User
        }
        do{
            let userResponse:UserResponse = try await Self.call(method: .get, url: "me", headers: headers)
            return userResponse.data
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
        
        struct GameRequest : Codable {
            let date:String
            let information:String?
            let status:String
            let winning_condition:String
            let ranking_type:String
            let initial_score:String
            let results:[[Int]]?
            let player1_id:Int
            let player2_id:Int
        }
            
        do {
            let gameResponse:GameResponse = try await Self.call(method: .post, url: "games", json:GameRequest(
                date : game.date.toISOString,
                information : game.information,
                status : game.status.rawValue,
                winning_condition : game.winning_condition.rawValue,
                ranking_type : game.ranking_type.rawValue,
                initial_score : InitialScore.standard.rawValue, //TODO
                results : game.results,
                player1_id : game.player1.id,
                player2_id : game.player2.id,
            ), headers: headers)            
            return gameResponse.data
            
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
            Http.call(method, Pongmatch.url + "api/" + url, json: json, headers:finalHeaders) { (_ response:T?, _ error:String?)  in
                guard let response else {
                    return continuation.resume(throwing: Errors.other(error ?? "Unknown error"))
                }
                return continuation.resume(returning: response)
            }
        }
    }
    
    private static func parseResponse<T:Decodable>(_ response:HttpResponse) throws -> T {
        print("API Response: " + response.toString)
        
        guard response.statusCode >= 200 && response.statusCode < 300 else {
            if response.statusCode == 401 { throw Errors.notAuthorized }
            if response.statusCode == 403 { throw Errors.forbidden }
            if response.statusCode == 404 { throw Errors.notFound }
            throw Errors.not200(response.statusCode)
        }
        
        guard let data = response.data else {
            throw Errors.emptyResponse
        }
        
        do {
            let response = try jsonDecoder().decode(T.self, from: data)
            return response
        } catch {
            print("API Error: \(error)")
            do {
                let errorResponse = try jsonDecoder().decode(ErrorResponse.self, from: data)
                throw Errors.errorResponse(errorResponse)
            } catch {
                throw error
            }
        }
    }
    
    private static func jsonDecoder() -> JSONDecoder{
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // For ISO 8601 format
        return decoder
    }
}
