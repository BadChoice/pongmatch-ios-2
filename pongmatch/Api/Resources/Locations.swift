internal import RevoFoundation
import RevoHttp
import UIKit

extension Api {
    class Locations {
        let client:ApiClient
        
        init(client:ApiClient){
            self.client = client
        }
        
        func locations(latitude: Double, longitude: Double) async throws -> [Location] {
            struct Response:Codable {
                let data:[Location]
            }
                        
            do {
                let response:Response = try await client.call(method: .get, url: "locations", params: [
                    "latitude" : latitude,
                    "longitude" : longitude
                ])
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        func location(id:Int) async throws -> Location {
            struct Response:Codable {
                let data:Location
            }
                        
            do {
                let response:Response = try await client.call(method: .get, url: "locations/\(id)")
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        func createLocation(name:String, isPrivate:Bool, isIndoor:Bool, numberOfTables:Int, description:String, instructions:String, address:String, longitude:Double, latitude:Double) async throws -> Location {
            struct Response:Codable {
                let data:Location
            }
                        
            do {
                let response:Response = try await client.call(method: .post, url: "locations", params:[
                    "name" :name,
                    "private" : isPrivate,
                    "indoor" : isIndoor,
                    "number_of_tables" : numberOfTables,
                    "description" : description,
                    "instructions" : instructions,
                    "address" : address,
                    "longitude" : longitude,
                    "latitude" : latitude,
                ])
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        func uploadLocationAvatar(_ location:Location, image:UIImage) async throws -> Location {

            try await withCheckedThrowingContinuation { continuation in
                struct Response : Codable {
                    let data:Location
                }
                
                let request = MultipartHttpRequest(method: .post, url: Pongmatch.url + "api/locations/\(location.id)/photo", headers: client.headers)
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
        
        // New: Update an existing location
        func update(location: Location, name: String, isPrivate: Bool, isIndoor: Bool, numberOfTables: Int, description: String, instructions: String) async throws -> Location {
            struct Response: Codable {
                let data: Location
            }
            do {
                let response: Response = try await client.call(
                    method: .put,
                    url: "locations/\(location.id)",
                    params: [
                        "name": name,
                        "private": isPrivate,
                        "indoor": isIndoor,
                        "number_of_tables": numberOfTables,
                        "description": description,
                        "instructions": instructions
                    ],
                    headers: [
                        "Content-Type": "application/x-www-form-urlencoded"
                    ]
                )
                return response.data
            } catch {
                print(error)
                throw error
            }
        }
        
        // New: Delete a location
        func delete(location: Location) async throws {
            struct Response: Codable { }
            do {
                let _: Response = try await client.call(method: .delete, url: "locations/\(location.id)")
            } catch {
                print(error)
                throw error
            }
        }
    }
}
