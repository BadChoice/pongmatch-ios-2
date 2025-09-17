//
//  ContentView.swift
//  pongmatch-watch Watch App
//
//  Created by Jordi Puigdellívol on 6/9/25.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var syncedScoreboard = SyncedScore.shared
    @StateObject private var path = NavigationManager()
    
    var body: some View {
        NavigationStack(path: $path.path) {
            VStack {
                Text("Pongmatch")
                if syncedScoreboard.score != nil {
                    NavigationLink("Continue match"){
                        ScoreboardView()
                    }
                }
                
                NavigationLink("New match") {
                    ScoreboardSelectionView()                    
                }
            }
            .padding()
        }
        .environmentObject(path)
    }
}

#Preview {
    ContentView()
}
