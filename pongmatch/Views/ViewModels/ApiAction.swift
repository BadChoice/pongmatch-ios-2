import SwiftUI
import Combine

@MainActor
class ApiAction: ObservableObject {
    @Published var loading: Bool = false
    @Published var errorMessage: String? = nil

    func run(_ block: () async throws -> Void) async -> Bool {        
        loading = true
        errorMessage = nil
        do {
            try await block()
        } catch {
            self.errorMessage = "\(error)"
        }
        
        loading = false
        return errorMessage == nil
    }

}

