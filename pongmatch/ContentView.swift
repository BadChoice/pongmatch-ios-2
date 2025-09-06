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
    @Query private var items: [Item]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NavigationLink("Scoreboard") {
                    ScoreboardView(score:Score(player1: User.me(), player2: User.unknown()))
                }
                .glassEffect()
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Pongmatch")
            .padding()
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
