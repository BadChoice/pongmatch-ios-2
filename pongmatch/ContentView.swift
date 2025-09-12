//
//  ContentView.swift
//  pongmatch
//
//  Created by Jordi Puigdellívol on 5/9/25.
//

import SwiftUI
import SwiftData


/**
 [ ] Push notifications
 [ ] Follow / Unfollow users
 [ ] Finish and upload game from watch.
 */

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var auth = AuthViewModel()
    @StateObject private var path = NavigationManager()
    
    var body: some View {
        Group {
            if auth.isAuthenticated {
                NavigationStack(path: $path.path) {
                    DashboardView()                        
                }
            } else {
                NavigationStack(path: $path.path) {
                    LoginView()
                }
            }
        }
        .environmentObject(auth)
        .environmentObject(path)
    }
}

#Preview {
    ContentView()
        //.modelContainer(for: Item.self, inMemory: true)
}
