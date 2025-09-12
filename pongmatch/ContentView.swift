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
 [ ] Scoreboard without login in
 [ ] Follow / Unfollow users
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
                LoginView()
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
