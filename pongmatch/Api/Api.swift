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
 
    var me: Me                  { Me(client: client) }
    var users: Users            { Users(client: client) }
    var games: Games            { Games(client: client) }
    var tournaments:Tournaments { Tournaments(client: client) }
    var groups: Groups          { Groups(client: client) }
    var locations: Locations    { Locations(client: client) }
    
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
