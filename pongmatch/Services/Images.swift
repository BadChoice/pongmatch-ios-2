import Foundation
import SwiftUI

struct Images {
    
    private static let imageCache = NSCache<NSString, UIImage>()
    
    static func avatar(_ avatar:String?) -> URL? {
        guard let avatar else { return nil }
        if avatar.hasPrefix("http") { return URL(string: avatar) }
        
        return URL(string: "\(Pongmatch.url)storage/avatars/\(avatar)")
    }
    
    // Download or retrieve cached image
    static func download(_ url: URL?) async -> UIImage? {
        guard let url = url else { return nil }
        let urlString = url.absoluteString as NSString
        
        // Check cache first
        if let cachedImage = imageCache.object(forKey: urlString) {
            return cachedImage
        }
        
        // Download image if not cached
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else { return nil }
            
            // Store in cache
            imageCache.setObject(image, forKey: urlString)
            return image
        } catch {
            print("Failed to download image from \(url): \(error)")
            return nil
        }
    }
    
    // New: Download and also expose HTTP status code so callers can detect 404s
    static func downloadWithStatus(_ url: URL?) async -> (image: UIImage?, statusCode: Int?) {
        guard let url = url else { return (nil, nil) }
        let urlString = url.absoluteString as NSString
        
        // Check cache first
        if let cachedImage = imageCache.object(forKey: urlString) {
            return (cachedImage, 200)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let http = response as? HTTPURLResponse
            let status = http?.statusCode
            
            // If it's not 200, don't attempt to build/cache the image
            guard status == 200 else {
                return (nil, status)
            }
            
            guard let image = UIImage(data: data) else {
                return (nil, status)
            }
            
            imageCache.setObject(image, forKey: urlString)
            return (image, status)
        } catch {
            print("Failed to download image from \(url): \(error)")
            return (nil, nil)
        }
    }
}

