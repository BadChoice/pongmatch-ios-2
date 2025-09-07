import Foundation
import RevoHttp


class Api {
    
    enum Errors : Error {
        case generic
        case cantDecodeResponse
        case emptyResponse
    }
    
    static let url = "http://pongmatch.test/api/"
    
    let token:String
    
    init(_ token:String){
        self.token = token
    }

    static func token(email:String, password:String, deviceName:String) async throws -> String {
        
        struct TokenResponse : Codable {
            let token:String
        }
        
        let response:TokenResponse = try await Self.call(method: .post, url: url + "token", params:[
            "email": email,
            "password": password,
            "device_name" : deviceName
        ])
        
        return response.token
    }
    
    var headers:[String:String] {
        [
            "Authentication" : "Bearer \(token)",
            "Accept": "application/json",
        ]
    }
    
    static func call<T:Decodable>(method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async throws -> T {
        
        try await withCheckedThrowingContinuation { continuation in
            Http.post(url, params: params) { response in
                guard response.statusCode >= 200 && response.statusCode < 300 else {
                    return continuation.resume(throwing: Errors.generic)
                }
                
                guard let data = response.data else {
                    return continuation.resume(throwing: Errors.emptyResponse)
                }
                
                print("API Response: " + response.toString)
                
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
