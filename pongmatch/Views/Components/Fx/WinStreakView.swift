import SwiftUI

struct WinStreakView : View {
    
    let count: Int?
    let size: CGFloat
    let speed: Double
    let shakeIntensity: CGFloat
    
    init(count: Int? = nil, size: CGFloat = 50, speed: Double = 1, shakeIntensity: CGFloat = 0) {
        self.count = count
        self.size = size
        self.speed = speed
        self.shakeIntensity = shakeIntensity
    }
    
    var body: some View {
        VStack {
            ZStack {
                FlameStreakView(speed: speed)
                    .frame(width: size, height: size)
                
                if let count {
                    Text("\(count)")
                        .font(.system(size: size/2, weight:.heavy, design:.rounded))
                        .bold()
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 2)
                        .offset(y: size / 8)
                        .shake(intensity: shakeIntensity, speed: 6, axis: .horizontal)
                        .shake(intensity: shakeIntensity, speed: 7, axis: .vertical)
                }
            }
        }
    }
}



#Preview {
    HStack {
        WinStreakView(size: 40, speed: 3, shakeIntensity: 1)
        WinStreakView(count: 1, size: 40, speed: 1, shakeIntensity: 0)
        WinStreakView(count: 1, size: 40, speed: 1, shakeIntensity: 0.5)
        WinStreakView(count: 10, size: 50, speed: 2, shakeIntensity: 1)
        WinStreakView(count: 100, size: 80, speed: 5, shakeIntensity: 2)
    }
}
