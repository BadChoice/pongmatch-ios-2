import SwiftUI
import Combine

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    // Optional helper functions
    func push<T: Hashable>(_ value: T) {
        path.append(value)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}
