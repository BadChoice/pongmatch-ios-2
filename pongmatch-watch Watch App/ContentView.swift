//
//  ContentView.swift
//  pongmatch-watch Watch App
//
//  Created by Jordi Puigdellívol on 6/9/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Pongmatch")
                NavigationLink("Start match") {
                    ScoreboardView(score: Score(
                        player1: User.me(),
                        player2: User.unknown()
                    ))
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
