import SwiftUI

struct DisputeView : View {
    @EnvironmentObject var auth: AuthViewModel
    let game:Game
    
    var body: some View {
        VStack(alignment:.leading, spacing: 10) {
            
            HStack {
                Text("Dispute")
                    .font(.headline)
                Spacer()
                Label("open", systemImage: "flag")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.black)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                    .font(.subheadline.bold())
            }
            
            
            HStack {
                if let disputer = disputer() {
                    AvatarView(user: disputer).frame(width: 20, height: 20)
                    Text("\(disputer.name)")
                        .font(.caption)
                }
                Spacer()
                Text(game.dispute!.created_at.displayForHumans)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text("\(game.dispute!.reason)")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            if accepter().id == auth.user.id {
                Button("Accept") {
                    
                }
            }
        
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)

    }
    
    private func disputer() -> User? {
        if game.player1.id == game.dispute?.user_id {
            return game.player1
        }
        if game.player2.id == game.dispute?.user_id {
            return game.player2
        }
        return nil
    }
    
    private func accepter() -> User {
        if game.player1.id == game.dispute?.user_id {
            return game.player2
        }
        return game.player1
    }
}

#Preview {
    DisputeView(
        game: Game.fakeDisputed()
    ).environmentObject(AuthViewModel())
}
