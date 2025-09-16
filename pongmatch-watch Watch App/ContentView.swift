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
                    ScoreboardView(score: Score(game:
                        Game(
                            id: nil,
                            ranking_type: .friendly,
                            winning_condition: .bestof3,
                            information: nil,
                            date: Date(),
                            status: .ongoing,
                            player1: User.me(),
                            player2: User.unknown()
                        )
                    ))
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
