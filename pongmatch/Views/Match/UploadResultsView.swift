import SwiftUI

struct UploadResultsView: View {
    
    @Binding var game: Game
    
    @EnvironmentObject var auth: AuthViewModel
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
                                    let isValid = Result(
                                        player1:setResults[idx][0],
                                        player2: setResults[idx][1]
                                    ).isValid()
                                    
                                    Text("Set \(idx + 1)")
                                        .font(.subheadline)
                                        .foregroundStyle(isValid ? .black : .red)
                                        .bold(!isValid)
                                    
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
            .disabled(!areResultsValid || uploading)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
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
    
    var areResultsValid: Bool {
        setResults.allSatisfy {
            Result(player1: $0[0], player2: $0[1]).isValid()
        }
    }
    
    private func uploadResults() async {
        uploading = true
        defer { uploading = false }
        errorMessage = nil
        do {
            game = try await auth.api.uploadResults(game, results: setResults)
            dismiss()
        } catch {
            errorMessage = "\(error)"
        }
    }
}


#Preview {
    @Previewable @State var game = Game.fake()
    UploadResultsView(game:$game)
}
