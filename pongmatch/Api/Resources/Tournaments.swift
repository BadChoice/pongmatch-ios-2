internal import RevoFoundation
import RevoHttp
import UIKit

extension Api {
    class Tournaments {
        let client:ApiClient
        
        init(client:ApiClient){
            self.client = client
        }
        
        func index() async throws -> [Tournament] {
            struct Response:Codable {
                let data:[Tournament]
            }
                        
            do {
                let response:Response = try await client.call(method: .get, url: "tournaments")
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        
        struct TournamentDetails : Codable {
            let games:[Game]
            let players:[User]
        }
        
        func get(id:Int) async throws -> TournamentDetails {
            struct Response:Codable {
                let data:TournamentDetails
            }

            do {
                let response:Response = try await client.call(method: .get, url: "tournaments/\(id)")
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
    }
}

