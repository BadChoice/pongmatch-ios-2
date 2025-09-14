import SwiftUI

struct UploadResultsView: View {
    let game: Game
    @Environment(\.dismiss) private var dismiss
    @State private var setResults: [[Int]] = [[0,0]]
    var player1: User { game.player1 }
    var player2: User { game.player2 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Enter Set Results")
                .font(.title2.bold())
                .padding(.bottom, 8)
            
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
                    Spacer().frame(height:25)
                    AvatarView(user: player1).frame(width:30)
                    AvatarView(user: player2).frame(width:30)
                }
                    ScrollView(.horizontal) {
                        HStack{
                            ForEach(setResults.indices, id: \ .self) { idx in
                                VStack(alignment: .trailing){
                                    Text("Set \(idx + 1)")
                                        .font(.subheadline)
                                        .frame(width: 50)
                                    
                                    Stepper(value: $setResults[idx][0], in: 0...99) {
                                        Text("\(setResults[idx][0])")
                                            .frame(width: 50)
                                    }
                                    Stepper(value: $setResults[idx][1], in: 0...99) {
                                        Text("\(setResults[idx][1])")
                                            .frame(width: 50)
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
            
            
            
            Divider()
            Button {
                // TODO: Upload results logic here
                dismiss()
            } label:{
                Label("Upload results", systemImage: "arrow.up.doc")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(.black)
            .foregroundStyle(.white)
            .clipShape(.capsule)
            Spacer()
        }
        .padding()
    }
}


#Preview {
    UploadResultsView(game:Game.fake())
}
