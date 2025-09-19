import Foundation

struct Pongmatch {
    #if targetEnvironment(simulator)
    static let url = "http://pongmatch.test/"
    #else
    static let url = "https://pongmatch.app/"
    #endif
    
    
    static var forgotPasswordUrl: URL {
        URL(string: url + "forgot-password")!
    }
}
