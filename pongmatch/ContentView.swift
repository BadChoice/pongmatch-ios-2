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
    @State private var showWhatsNew = false
    
    var body: some View {
        Group {
            if auth.isAuthenticated {
                DashboardView()
            } else {
                LoginView()
            }
        }
        .environmentObject(auth)
        .task {
            if WhatsNewManager.shouldShow() {
                showWhatsNew = true
            }
        }
        .sheet(isPresented: $showWhatsNew) {
            WhatsNewView {
                WhatsNewManager.markShown()
                showWhatsNew = false
            }        
        }
    }
}

#Preview {
    ContentView()
        //.modelContainer(for: Item.self, inMemory: true)
}
