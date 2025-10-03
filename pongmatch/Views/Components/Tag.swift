import SwiftUI

struct Tag : View {
    let text: String
    let color: Color
    let icon: String?
    
    init(_ text: String, icon: String? = nil, color: Color = .gray) {
        self.text = text
        self.color = color
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Label(text, systemImage: icon)
            }else{
                Text(text)
            }
        }
        .font(.footnote)
        .bold()
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .clipShape(Capsule())
    }

}

#Preview {
    VStack {
        Tag("Pro", icon: "star.fill", color: .purple)
        Tag("New", icon: "sparkles", color: .green)
        Tag("Beginner", color: .blue)
        Tag("Offline", icon: "wifi.slash", color: .red)
        Tag("Online", icon: "wifi")
    }
}
