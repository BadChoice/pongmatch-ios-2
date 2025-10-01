import SwiftUI

struct ComboBadgeView : View{
    let combo:ScoreCombo?
    
    var body: some View{
        
        HStack (alignment:.center) {
            if let combo {
                FlameStreakView(speed:6 * combo.intensity)
                    .frame(width: 30, height:30)
                    .offset(y:-5)
                
                Text(combo.description)
                    .font(combo.font)
                    .foregroundStyle(combo.color)
            } else {
                Spacer().frame(height:30)
            }
            
        }
    }
}

#Preview{
    VStack{
        ComboBadgeView(combo: .perfect)
        ComboBadgeView(combo: .matchPoint11_0)
        ComboBadgeView(combo: .gettingTo11_0)
        
        ComboBadgeView(combo: .matchPoint)
        
        ComboBadgeView(combo: .streak9Points)
        ComboBadgeView(combo: .streak7Points)
        ComboBadgeView(combo: .streak5Points)
        ComboBadgeView(combo: .streak3Points)
        
        ComboBadgeView(combo: nil)
    }
}
