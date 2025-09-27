// Gravatar.swift
import Foundation
import UIKit
import CryptoKit

enum Gravatar {
    enum DefaultImage: String {
        case mp
        case identicon
        case monsterid
        case wavatar
        case retro
        case robohash
        case blank
        case _404 = "404"
    }
    
    enum Rating: String {
        case g, pg, r, x
    }
    
    static func url(
        email: String?,
        size: Int = 256,
        defaultImage: DefaultImage = .mp,
        rating: Rating = .g,
        forceDefault: Bool = false
    ) -> URL? {
        guard let hash = md5(from: email) else { return nil }
        let clampedSize = max(1, min(size, 2048))
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.gravatar.com"
        components.path = "/avatar/\(hash)"
        var items = [
            URLQueryItem(name: "s", value: "\(clampedSize)"),
            URLQueryItem(name: "d", value: defaultImage.rawValue),
            URLQueryItem(name: "r", value: rating.rawValue)
        ]
        if forceDefault {
            items.append(URLQueryItem(name: "f", value: "y"))
        }
        components.queryItems = items
        return components.url
    }
    
    static func fetch(
        email: String?,
        size: Int = 256,
        defaultImage: DefaultImage = ._404,
        rating: Rating = .g,
        forceDefault: Bool = false
    ) async -> UIImage? {
        let url = url(email: email, size: size, defaultImage: defaultImage, rating: rating, forceDefault: forceDefault)
        return await Images.download(url)
    }
    
    private static func md5(from email: String?) -> String? {
        guard let raw = email?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased(),
              !raw.isEmpty
        else { return nil }
        
        let digest = Insecure.MD5.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
