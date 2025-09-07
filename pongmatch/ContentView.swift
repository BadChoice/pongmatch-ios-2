//
//  ContentView.swift
//  pongmatch
//
//  Created by Jordi Puigdellívol on 5/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var session = AuthViewModel()
    
    var body: some View {
        Group {
            if session.isAuthenticated {
                NavigationStack {
                    DashboardView()
                        .toolbar {
                            Button("Logout") { session.logout() }
                        }
                }
            } else {
                LoginView()
            }
        }.environmentObject(session)
    }
}

#Preview {
    ContentView()
        //.modelContainer(for: Item.self, inMemory: true)
}
