import Foundation
import RevoHttp


class Api {
    
    enum Errors : Error, CustomStringConvertible {
        case not200(_ status:Int)
        case cantDecodeResponse
        case emptyResponse
        case errorResponse(_ error:ErrorResponse)
        
        var description: String {
            switch self {
            case .not200(let status): return "Invalid credentials or server error. \(status)"
            case .cantDecodeResponse: return "Unexpected server response."
            case .emptyResponse: return "No data received from server."
            case .errorResponse(let error): return "Error response \(error.message)"
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
    
    func searchFriends(_ text:String?) async throws -> [User] {
        guard let text, !text.isEmpty else { return[] }
        
        struct FriendsResponse : Codable {
            let data:[User]
        }
        
        do {
            let userResponse:FriendsResponse = try await Self.call(method: .get, url: "friends/search/\(text)", headers: headers)
            return userResponse.data
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
            print("Calling API: \(method) \(url)")
            Http.call(method, url:Pongmatch.url + "api/" + url, params: params, headers:headers) { response in
                
                print("API Response: " + response.toString)
                
                guard response.statusCode >= 200 && response.statusCode < 300 else {
                    return continuation.resume(throwing: Errors.not200(response.statusCode))
                }
                
                guard let data = response.data else {
                    return continuation.resume(throwing: Errors.emptyResponse)
                }                
                
                do {
                    let response = try jsonDecoder().decode(T.self, from: data)
                    continuation.resume(returning: response)
                } catch {
                    print("API Error: \(error)")
                    do {
                        let errorResponse = try jsonDecoder().decode(ErrorResponse.self, from: data)
                        continuation.resume(throwing: Errors.errorResponse(errorResponse))
                    } catch {
                        return continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private static func jsonDecoder() -> JSONDecoder{
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // For ISO 8601 format
        return decoder
    }
}
