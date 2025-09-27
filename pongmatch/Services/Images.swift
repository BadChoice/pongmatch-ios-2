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
    static func download(_ url: URL?, skipCache:Bool = false) async -> UIImage? {
        guard let url = url else { return nil }
        let urlString = url.absoluteString as NSString
        
        // Check cache first
        if !skipCache, let cachedImage = imageCache.object(forKey: urlString) {
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
}
