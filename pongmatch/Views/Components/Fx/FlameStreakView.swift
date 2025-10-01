import SwiftUI

/// A simple, cartoony, fast‑moving win‑streak flame (3 colors: red body, yellow core, black border).
/// Drop it anywhere and size with .frame(...).
struct FlameStreakView: View {
    /// Speed multiplier for animation (1.0 is fast; increase for even faster).
    var speed: Double = 1.0
    
    /// Colors (default: red body, yellow core, black border).
    var bodyColor: Color = .red
    var coreColor: Color = .yellow
    var borderColor: Color = .black
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            
            // Fast flicker and sway
            let sway = sin(t * 6.5 * speed)                     // -1...1
            let flicker = 0.5 + 0.5 * sin(t * 9.0 * speed + 0.7) // 0...1
            let taper = 0.5 + 0.5 * sin(t * 7.0 * speed + 1.1)   // 0...1
            let flare = 0.25 + 0.10 * flicker                    // width bulge
            
            GeometryReader { proxy in
                let s = min(proxy.size.width, proxy.size.height)
                let stroke = max(1.0, s * 0.08) // bold, cartoony border scales with size
                
                ZStack {
                    // Outer red body
                    FlameShape(sway: CGFloat(sway),
                               flare: CGFloat(flare),
                               taper: CGFloat(taper))
                        .fill(bodyColor)
                    
                    // Black outline
                    FlameShape(sway: CGFloat(sway),
                               flare: CGFloat(flare),
                               taper: CGFloat(taper))
                        .stroke(borderColor, lineWidth: stroke)
                    
                    // Inner yellow core: slightly smaller and rising
                    FlameShape(sway: CGFloat(sin(t * 7.5 * speed + 0.8) * 0.9),
                               flare: CGFloat(0.22 + 0.10 * (0.5 + 0.5 * sin(t * 10.0 * speed + 1.3))),
                               taper: CGFloat(0.5 + 0.5 * sin(t * 8.0 * speed + 2.1)))
                        .fill(coreColor)
                        .scaleEffect(0.62 + 0.03 * CGFloat(flicker), anchor: .bottom)
                        .offset(y: -s * 0.06) // hot core sits a bit higher
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .bottom)
            }
            // Tiny, fast overall wobble for extra life
            .rotationEffect(.degrees(sin(t * 5.0 * speed) * 1.6))
            .scaleEffect(0.98 + 0.02 * CGFloat(flicker), anchor: .bottom)
        }
    }
}

/// A simple teardrop‑like flame with tunable sway, flare, and taper.
/// - sway: horizontal tip offset (-1...1)
/// - flare: side bulge (0...1)
/// - taper: tip height variance (0...1)
private struct FlameShape: Shape {
    var sway: CGFloat   // -1...1
    var flare: CGFloat  // 0...1
    var taper: CGFloat  // 0...1
    
    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>> {
        get { AnimatablePair(sway, AnimatablePair(flare, taper)) }
        set {
            sway = newValue.first
            flare = newValue.second.first
            taper = newValue.second.second
        }
    }
    
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        
        // Base and tip positions
        let baseY = rect.maxY - h * 0.04
        let leftBaseX = rect.minX + w * 0.22
        let rightBaseX = rect.maxX - w * 0.22
        
        let tipX = rect.midX + sway * w * 0.12
        let tipY = rect.minY + h * (0.10 + 0.06 * (1.0 - taper))
        
        let leftBase = CGPoint(x: leftBaseX, y: baseY)
        let rightBase = CGPoint(x: rightBaseX, y: baseY)
        let tip = CGPoint(x: tipX, y: tipY)
        
        // Curvy sides control points to get a cartoony flame
        let c1L = CGPoint(x: leftBaseX - w * 0.10 * flare, y: baseY - h * 0.22)
        let c2L = CGPoint(x: rect.midX - w * 0.58 * flare, y: rect.midY - h * (0.30 + 0.05 * (1.0 - taper)))
        
        let c2R = CGPoint(x: rect.midX + w * 0.58 * flare, y: rect.midY - h * (0.30 + 0.05 * (1.0 - taper)))
        let c1R = CGPoint(x: rightBaseX + w * 0.10 * flare, y: baseY - h * 0.22)
        
        var p = Path()
        p.move(to: leftBase)
        p.addCurve(to: tip, control1: c1L, control2: c2L)
        p.addCurve(to: rightBase, control1: c2R, control2: c1R)
        // Slightly concave bottom
        p.addQuadCurve(to: leftBase, control: CGPoint(x: rect.midX, y: rect.maxY - h * 0.02))
        p.closeSubpath()
        return p
    }
}

#Preview {
    VStack(spacing: 24) {
        FlameStreakView()
            .frame(width: 56, height: 80)
        FlameStreakView(speed: 1.4)
            .frame(width: 84, height: 120)
        HStack(spacing: 16) {
            FlameStreakView(speed: 1.0)
            FlameStreakView(speed: 1.8)
            FlameStreakView(speed: 2.4)
            FlameStreakView(speed: 5)
        }
        .frame(height: 80)
    }
    .padding()
}
