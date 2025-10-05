internal import RevoFoundation
import RevoHttp

extension Api {
    class Games {
        let client:ApiClient
        
        init(client:ApiClient){
            self.client = client
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
        
        func dispute(_ game:Game, reason:String) async throws -> Game {
            guard !game.needsId else {
                throw ApiClient.Errors.other("Game ID is nil")
            }
            
            struct Response : Codable {
                let data:Game
            }
            
            do{
                let response:Response = try await client.call(method: .post, url: "games/\(game.id)/dispute", params:[
                    "reason" : reason
                ])
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
        
        
    }
}
