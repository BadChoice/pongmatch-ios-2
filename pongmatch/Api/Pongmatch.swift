struct Pongmatch {
    #if targetEnvironment(simulator)
    static let url = "http://pongmatch.test/"
    #else
    static let url = "https://pongmatch.app/"
    #endif
}
