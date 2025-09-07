import SwiftUI
import Combine

@MainActor
class AuthViewModel : ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        if Storage().get(.apiToken) != nil {
            isAuthenticated = true
        }
    }
    
    func login(email: String, password: String, deviceName: String) async {
        guard !isLoading else { return }
        
        errorMessage = nil
        isLoading = true
        
        do {
            let token = try await Api.login(email: email, password: password, deviceName: deviceName)
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
}
