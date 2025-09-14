import SwiftUI

struct UploadResultsView: View {
    
    let game: Game
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var nav: NavigationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var uploading: Bool = false
    @State private var errorMessage: String?
    
    @State private var setResults: [[Int]] = [[0,0]]
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter Set Results")
                .font(.title2.bold())
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                
                HStack {
                    Spacer()
                    Button(action: {
                        setResults.append([0,0])
                    }) {
                        Image(systemName: "plus.circle")
                    }
                }
                
                HStack {
                    VStack {
                        Spacer().frame(height:22)
                        AvatarView(user: game.player1)//.frame(width:40)
                        AvatarView(user: game.player2)//.frame(width:40)
                    }.frame(height:100)
                    ScrollView(.horizontal) {
                        HStack(spacing: 8){
                            ForEach(setResults.indices, id: \ .self) { idx in
                                VStack(alignment: .trailing){
                                    Text("Set \(idx + 1)")
                                        .font(.subheadline)
                                    
                                    Stepper(value: $setResults[idx][0], in: 0...99) {
                                        Text("\(setResults[idx][0])")
                                            //.frame(width: 25)
                                    }
                                    Stepper(value: $setResults[idx][1], in: 0...99) {
                                        Text("\(setResults[idx][1])")
                                            //.frame(width: 25)
                                    }
                                }
                            }
                        }.padding()
                    }
                }
                
                HStack {
                    Spacer()
                    
                    if setResults.count > 1 {
                        Button(action: {
                            setResults.removeLast()
                        }) {
                            Label("Remove Set", systemImage: "minus.circle")
                        }
                    }
                }
            }

            Spacer()
            
            Button {
                Task {
                    await uploadResults()
                }
            } label:{
                if uploading {
                    ProgressView().tint(.white)
                } else {
                    Label("Upload results", systemImage: "arrow.up.circle.fill")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.black)
            .foregroundStyle(.white)
            .clipShape(.capsule)
            
            if let errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
    
    private func uploadResults() async {
        uploading = true
        defer { uploading = false }
        errorMessage = nil
        do {
            let _ = try await auth.api.uploadResults(game, results: setResults)
            nav.popToRoot()
            try await auth.loadGames()
        } catch {
            errorMessage = "\(error)"
        }
    }
}


#Preview {
    UploadResultsView(game:Game.fake())
}
