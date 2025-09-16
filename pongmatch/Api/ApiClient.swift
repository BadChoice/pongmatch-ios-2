import Foundation
import UIKit
import RevoHttp
internal import RevoFoundation


class ApiClient {
        
    struct ErrorResponse : Codable {
        let message:String
        let errors:[String:[String]]?
    }

    
    enum Errors : Error, CustomStringConvertible {
        case not200(_ status:Int, _ error:ErrorResponse? = nil)
        case notAuthorized
        case forbidden
        case notFound
        case unprocessableContent(_ error:ErrorResponse?)
        
        case cantDecodeResponse
        case emptyResponse
        case errorResponse(_ error:ErrorResponse?)
        case other(_ error:String)
        
        var description: String {
            switch self {
            case .not200(let status, let error): error?.message ?? "Can't process the request. \(status)"
            case .notAuthorized: "Not authorized."
            case .forbidden: "Forbidden."
            case .notFound: "Not found."
            case .unprocessableContent(let error): error?.message ?? "Unprocessable content."
            case .cantDecodeResponse: "Unexpected server response."
            case .emptyResponse: "No data received from server."
            case .errorResponse(let error): error?.message  ?? "Can't process the request."
            case .other(let error): "Other response \(error)"
            }
        }
    }
    
    
    let token:String
    
    init(_ token:String){
        self.token = token
    }
    
    var headers:[String:String] {
        [
            "Authorization" : "Bearer \(token)",
            "Accept": "application/json",
        ]
    }
    
    func call<T:Decodable>(method:HttpRequest.Method, url:String, params:[String:Codable] = [:]) async throws -> T {
        try await Self.call(method: method, url: url, params: params, headers: headers)
    }
    
    func call<T:Codable,Z:Encodable>(method:HttpRequest.Method, url:String, json:Z) async throws -> T {
        try await Self.call(method: method, url: url, json: json, headers: headers)
    }
    
    //MARK: - Static methods
    static func call<T:Decodable>(method:HttpRequest.Method, url:String, params:[String:Codable] = [:], headers:[String:String] = [:]) async throws -> T {
                
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
    
    static func call<T:Codable,Z:Encodable>(method:HttpRequest.Method, url:String, json:Z, headers:[String:String] = [:]) async throws -> T {
        try print("Calling API: \(method) \(url) \(json.jsonString())")
        
        let finalHeaders = headers.merging(["Content-Type": "application/json"]) { _, new in new }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<T, Error>) -> Void in
            Http.call(method, Pongmatch.url + "api/" + url, json: json, headers:finalHeaders) { response in
                do {
                    continuation.resume(returning: try parseResponse(response))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    static func parseResponse<T:Decodable>(_ response:HttpResponse) throws -> T {
        print("API Response: " + response.toString)
        
        var errorResponse: ErrorResponse? = nil
        if let data = response.data {
            errorResponse = try? jsonDecoder().decode(ErrorResponse.self, from: data)
        }
        
        guard response.statusCode >= 200 && response.statusCode < 300 else {
            if response.statusCode == 401 { throw Errors.notAuthorized }
            if response.statusCode == 403 { throw Errors.forbidden }
            if response.statusCode == 404 { throw Errors.notFound }
            if response.statusCode == 422 { throw Errors.unprocessableContent(errorResponse) }
            throw Errors.not200(response.statusCode, errorResponse)
        }
        
        guard let data = response.data else {
            throw Errors.emptyResponse
        }
        
        do {
            let response = try jsonDecoder().decode(T.self, from: data)
            return response
        } catch {
            print("API Error: \(error)")
            throw Errors.errorResponse(errorResponse)
        }
    }
    
    private static func jsonDecoder() -> JSONDecoder{
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // For ISO 8601 format
        return decoder
    }
}
