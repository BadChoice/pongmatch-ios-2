import SwiftUI
import Combine

@MainActor
class AuthViewModel : ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    var user:User!
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
            
            withAnimation { isAuthenticated = true }
        } catch {
            errorMessage = error.localizedDescription
        }
                
        isLoading = false
    }

    func logout() {
        Storage().save(.apiToken, value: nil)
        withAnimation { isAuthenticated = false }
    }
    
    func fetchMe() async throws {
        user = try await api.me()
    }
}
