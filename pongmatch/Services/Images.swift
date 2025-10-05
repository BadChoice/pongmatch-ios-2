import Foundation
import SwiftUI

struct Images {
    
    enum Folder: String {
        case avatars
        case groups
        case tournaments
        case locations
        case games
    }
    
    private static let imageCache = NSCache<NSString, UIImage>()
    
    static func url(_ photo:String?, folder:Folder) -> URL? {
        guard let photo else { return nil }
        if photo.hasPrefix("http") { return URL(string: photo) }
        
        return URL(string: "\(Pongmatch.url)storage/\(folder.rawValue)/\(photo)")
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
