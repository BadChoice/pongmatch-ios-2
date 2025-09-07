import Foundation
import RevoHttp


class Api {
    
    enum Errors : Error, CustomStringConvertible {
        case not200
        case cantDecodeResponse
        case emptyResponse
        
        var description: String {
            switch self {
            case .not200: return "Invalid credentials or server error."
            case .cantDecodeResponse: return "Unexpected server response."
            case .emptyResponse: return "No data received from server."
            }
        }
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
        try await Self.call(method: .get, url: "me", headers: headers)
    }
    
    var headers:[String:String] {
        [
            "Authorization" : "Bearer \(token)",
            "Accept": "application/json",
        ]
    }
    
    static func call<T:Decodable>(method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async throws -> T {
                
        try await withCheckedThrowingContinuation { continuation in
            print("Calling API: \(method) \(url)")
            Http.call(method, url:Pongmatch.url + "api/" + url, params: params, headers:headers) { response in
                
                print("API Response: " + response.toString)
                
                guard response.statusCode >= 200 && response.statusCode < 300 else {
                    return continuation.resume(throwing: Errors.not200)
                }
                
                guard let data = response.data else {
                    return continuation.resume(throwing: Errors.emptyResponse)
                }                
                
                do {
                    let response = try JSONDecoder().decode(T.self, from: data)
                    continuation.resume(returning: response)
                } catch {
                    return continuation.resume(throwing: error)
                }
            }
        }
    }
    
}
