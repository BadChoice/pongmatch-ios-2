internal import RevoFoundation
import RevoHttp
import UIKit

extension Api {
    class Me {
        let client:ApiClient
        
        init(client:ApiClient){
            self.client = client
        }
        
        func me() async throws -> User {
            struct UserResponse : Codable {
                var data:User
            }
            do{
                var userResponse:UserResponse = try await client.call(method: .get, url: "me")
                if let details = try? await Users(client: client).deepDetails(userResponse.data) {
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
                    "accept_challenge_requests_from": acceptChallengesFrom.rawValue,
                ], headers:[
                    "Content-Type" : "application/x-www-form-urlencoded"
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
        
        func deleteAccount() async throws {
            struct Response: Codable { }
            do {
                let _: Response = try await client.call(method: .delete, url: "me")
            } catch {
                print(error)
                throw error
            }
        }
    }
}
