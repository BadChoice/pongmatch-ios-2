import SwiftUI

struct PulseView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Expanding ring
            Circle()
                .stroke(Color.blue.opacity(0.4), lineWidth: 4)
                .frame(width: 20, height: 20)
                .scaleEffect(animate ? 1.5 : 1.0)
                .opacity(animate ? 0 : 1)
            
            // Static center dot
            Circle()
                .fill(Color.blue)
                .frame(width: 12, height: 12)
        }
        .onAppear {
            withAnimation(
                .easeOut(duration: 1.5)
                .repeatForever(autoreverses: false)
            ) {
                animate = true
            }
        }
    }
}
