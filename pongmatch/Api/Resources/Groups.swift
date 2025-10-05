internal import RevoFoundation
import RevoHttp
import UIKit

extension Api {
    class Groups {
        let client:ApiClient
        
        init(client:ApiClient){
            self.client = client
        }
        
        func create(name:String, description:String?, isPrivate:Bool) async throws -> PMGroup {
            struct Response:Codable {
                let data:PMGroup
            }
                
            do {
                let response:Response = try await client.call(method: .post, url: "groups", params:[
                    "name" : name,
                    "description" : description ?? "",
                    "private" : isPrivate ? 1 : 0
                ])
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        func update(_ group:PMGroup) async throws -> PMGroup {
            struct Response:Codable {
                let data:PMGroup
            }
            
            do {
                let response:Response = try await client.call(method: .put, url: "groups/\(group.id)", params:[
                    "name" : group.name,
                    "description" : group.description,
                    "private" : group.isPrivate
                ], headers:[
                    "Content-Type" : "application/x-www-form-urlencoded"
                ])
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        func uploadAvatar(_ group:PMGroup, image:UIImage) async throws -> PMGroup {

            try await withCheckedThrowingContinuation { continuation in
                struct Response : Codable {
                    let data:PMGroup
                }
                
                let request = MultipartHttpRequest(method: .post, url: Pongmatch.url + "api/groups/\(group.id)/photo", headers: client.headers)
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
        
        func index() async throws -> [PMGroup] {
            struct Response:Codable {
                let data:[PMGroup]
            }
                
            do {
                let response:Response = try await client.call(method: .get, url: "groups")
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        func users(_ group:PMGroup) async throws -> [User] {
            struct Response:Codable {
                let data:[User]
            }
                
            do {
                let response:Response = try await client.call(method: .get, url: "groups/\(group.id)/users")
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        func invite(user:User, to group:PMGroup) async throws {
            struct Response:Codable { }
                
            do {
                let _:Response = try await client.call(method: .post, url: "groups/\(group.id)/invite/\(user.id)")
            } catch {
                print(error)
                throw error
            }
        }
        
        func join(_ group:PMGroup) async throws -> PMGroup {
            struct Response:Codable {
                let data:PMGroup
            }
                
            do {
                let response:Response = try await client.call(method: .post, url: "groups/\(group.id)/join")
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        func leave(_ group:PMGroup) async throws {
            struct Response:Codable { }
                
            do {
                let _:Response = try await client.call(method: .post, url: "groups/\(group.id)/leave")
            } catch {
                print(error)
                throw error
            }
        }
    }
}
