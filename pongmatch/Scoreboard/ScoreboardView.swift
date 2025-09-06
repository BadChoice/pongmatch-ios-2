import SwiftUI

struct ScoreboardView : View {
    var body: some View {
        VStack(spacing: 20){
            HStack(spacing:24) {
                Text("Standard")
                Text("Friendly")
                Text("Best of 3")
            }
            
            HStack (spacing:40) {
                UserView(user: User(name: "Jordi Puigdellivol", elo: 1111, avavar: nil))
                UserView(user: User(name: "Gerard Miralles",    elo: 1111, avavar: nil))
            }
            
            HStack(alignment:.top, spacing: 40) {
                ScoreboardScoreView()
                ScoreboardScoreView()
            }
        }
    }
}

struct ScoreboardScoreView: View {
    
    var body: some View {
        VStack(alignment: .center){
            Text("0")
                .font(.system(size: 50, weight:.bold))
                .padding(28)
                .background(.cyan)
                .cornerRadius(8)
            
            HStack {
                Image(systemName: "circle.fill").font(.system(size: 8))
                Image(systemName: "circle.fill").font(.system(size: 8))
            }
            .foregroundStyle(.white)
            .padding(4)
            .background(.red)
            .clipShape(.capsule)
        }
    }
}


#Preview {
    ScoreboardView()
}
