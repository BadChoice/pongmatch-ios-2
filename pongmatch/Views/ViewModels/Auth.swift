import SwiftUI
import Combine
internal import RevoFoundation

@MainActor
class AuthViewModel : ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var user:User!
    @Published var games:[Game] = []
    var api:Api!
    
    init() {
        if let token = Storage().get(.apiToken) {
            api = Api(token)
            isAuthenticated = true
        }
    }
    
    func login(email: String, password: String, deviceName: String) async {
        guard !isLoading else { return }
        
        errorMessage = nil
        isLoading = true
        
        do {
            let token = try await Api.login(email: email, password: password, deviceName: deviceName)
            api = Api(token)
            Storage().save(.apiToken, value: token)
            try await fetchMe()
            withAnimation { isAuthenticated = true }
            
        } catch {
            errorMessage = "\(error)"
        }
                
        isLoading = false
    }
    
    func register(name:String, username:String, email:String, password:String, passwordConfirm:String, deviceName:String) async {
        guard !isLoading else { return }
        
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            let token = try await Api.register(
                name:name,
                username:username,
                email:email,
                password:password,
                passwordConfirm:passwordConfirm,
                deviceName:deviceName
            )
            api = Api(token)
            Storage().save(.apiToken, value: token)
            try await fetchMe()
            
            withAnimation { isAuthenticated = true }
            
        } catch {
            errorMessage = "\(error)"
        }
                
        
    }
    
    func loadGames() async throws {
        guard !isLoading else { return }
        
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        do {
            games = try await api.games.games()
                .sort(by: \.date)
                .reversed()
        } catch {
            errorMessage = "\(error)"
        }
            
    }


    func logout() {
        Storage().save(.apiToken, value: nil)
        withAnimation { isAuthenticated = false }
    }
    
    func fetchMe() async throws {
        user = try await api.me.me()
        WatchManager.shared.sendUserInfo(["auth_user" : try! user.encode()])
    }
    
    func friends() async throws -> [User] {
        try await api.users.friends()
    }
    
    func searchFriends(_ text:String?) async throws -> [User] {
        try await api.users.friends(search: text)
    }
}
