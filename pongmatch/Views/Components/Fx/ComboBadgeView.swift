import SwiftUI

struct ComboBadgeView : View{
    let combo:ScoreCombo?
    
    var body: some View{
        
        HStack (alignment:.center, spacing: 0) {
            if let combo {
                if case .pointsStreak(let streak) = combo {
                    WinStreakView(count:streak, size:30, speed:6 * combo.flameSpeed, shakeIntensity: combo.shakeIntensity)
                        .offset(y:-4)
                } else {
                    FlameStreakView(speed:6 * combo.flameSpeed)
                        .frame(width: 25, height:25)
                        .offset(y:-3)
                }
                Text(combo.description)
                    .font(.system(size: combo.fontSize, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.accent)
                    .shake(intensity: combo.shakeIntensity, speed: 6, axis:.horizontal)
                    .shake(intensity: combo.shakeIntensity, speed: 7, axis:.vertical)
                
                if case .perfect = combo {
                    FlameStreakView(speed:6 * combo.flameSpeed)
                        .frame(width: 25, height:25)
                        .offset(y:-3)
                } else if case .perfectMatchPoint = combo {
                    FlameStreakView(speed:6 * combo.flameSpeed)
                        .frame(width: 25, height:25)
                        .offset(y:-3)
                }
            } else {
                Spacer().frame(height:30)
            }
            
        }
    }
}

#Preview{
    VStack(spacing: 8){
        ComboBadgeView(combo: .perfect)
        ComboBadgeView(combo: .perfectMatchPoint)
        ComboBadgeView(combo: .roadToPerfect)
        
        ComboBadgeView(combo: .matchPoint)
        
        ComboBadgeView(combo: .pointsStreak(9))
        ComboBadgeView(combo: .pointsStreak(7))
        ComboBadgeView(combo: .pointsStreak(5))
        ComboBadgeView(combo: .pointsStreak(3))
        
        ComboBadgeView(combo: nil)
    }
}
