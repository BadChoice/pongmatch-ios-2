import SwiftUI

struct SmallGameView : View {
    let game:Game
    
    var body: some View {
        ZStack {
            BackgroundBlurredImage(user:game.player1, alpha:1)
            Color.black.opacity(0.25).ignoresSafeArea()
            
            
            VStack {
                HStack {
                    Text(game.ranking_type.description)
                    Spacer()
                    Text(game.winning_condition.description)
                }
                .font(.caption)
                .padding(.horizontal)
                .padding(.top, 8)
                .foregroundStyle(.white)
                
                HStack {
                    VStack{
                        AvatarView(user:game.player1)
                            .frame(width: 40,  height: 40)
                        Text(game.player1.initials)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }.frame(maxWidth:.infinity)
                    
                    FinalResult(game.finalResult)
                        .foregroundStyle(.white)
                        .frame(maxWidth:.infinity)
                    
                    VStack{
                        AvatarView(user:game.player2)
                            .frame(width: 40,  height: 40)
                        Text(game.player2.initials)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }.frame(maxWidth:.infinity)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            

        }
        .frame(width: 260, height: 120)
        .cornerRadius(20)
        .overlay(alignment:.top) {
            Label("Finished", systemImage: "flag.checkered")
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black)
                .foregroundStyle(.white)
                .clipShape(.capsule)
                .offset(x:0, y:-10)
        }
        .overlay(alignment:.bottom) {
            Text(Date().compactDisplay)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .offset(x:0, y:-14)
        }
        //.shadow(radius: 5)
    }
}

#Preview {
    VStack(spacing:40) {
        SmallGameView(game:Game.fake())
        
        SmallGameView(game:Game.fake(
            player1:User.unknown(),
            player2:User.me())
        )
    }
}
