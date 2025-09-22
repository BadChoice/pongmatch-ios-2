import SwiftUI

struct WinLossBar: View {
    let me:User
    let friend:User
    let wins: Int
    let losses: Int
    let label:String?
    
    private var total: Int { max(wins + losses, 0) }
    private var winRatio: CGFloat {
        guard total > 0 else { return 0.5 } // neutral split when no data
        return CGFloat(wins) / CGFloat(total)
    }
    
    private var winRatioPercentInt: Int {
        Int((winRatio * 100).rounded())
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                AvatarView(user: me)
                    .frame(width: 24, height:24)
                Text("\(wins)")
                    .bold()
                    //.font(.caption)
                    .foregroundStyle(.green)
                Spacer()
                Text(label ?? "Win Ratio")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("\(winRatioPercentInt)%")
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(losses)")
                    .bold()
                    //.font(.caption)
                    .foregroundStyle(.red)
                AvatarView(user: friend)
                    .frame(width: 24, height:24)
            }
            
            GeometryReader { geo in
                let width = geo.size.width
                let leftWidth = max(0, min(width, width * winRatio))
                let rightWidth = width - leftWidth
                
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))
                    
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.green.opacity(0.8))
                            .frame(width: leftWidth)
                        
                        Rectangle()
                            .fill(Color.red.opacity(0.8))
                            .frame(width: rightWidth)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .frame(height: 14)
        }
        .animation(.easeInOut(duration: 0.25), value: wins)
        .animation(.easeInOut(duration: 0.25), value: losses)
    }
}

#Preview {
    VStack(spacing: 24) {
        WinLossBar(me: User.me(), friend: User.unknown(), wins:7, losses: 3, label: nil)
        WinLossBar(me: User.me(), friend: User.unknown(), wins: 12, losses: 25, label: nil)
        WinLossBar(me: User.me(), friend: User.unknown(), wins: 1, losses: 0, label: nil)
        WinLossBar(me: User.me(), friend: User.unknown(), wins: 0, losses: 9, label: nil)
    }
}
