import SwiftUI

struct NoSleep: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
    }
}

extension View {
    func noSleep() -> some View {
        self.modifier(NoSleep())
    }
}
