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
    
    @StateObject private var auth = AuthViewModel()
    
    var body: some View {
        Group {
            if auth.isAuthenticated {
                NavigationStack {
                    DashboardView()                        
                }
            } else {
                LoginView()
            }
        }.environmentObject(auth)
    }
}

#Preview {
    ContentView()
        //.modelContainer(for: Item.self, inMemory: true)
}
