import Foundation

struct Pongmatch {
    #if targetEnvironment(simulator)
    static let url = "http://pongmatch.test/"
    #else
    static let url = "https://pongmatch.app/"
    #endif
    
    static let appStoreId = "6752864484"
    static let appStoreUrl = "https://apps.apple.com/app/id\(appStoreId)"    
    
    static var forgotPasswordUrl: URL {
        URL(string: url + "forgot-password")!
    }
}
