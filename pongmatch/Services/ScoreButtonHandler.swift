import Foundation

class ScoreButtonHandler {
    
    private var pressCount = 0
    private var resetTimer: Timer?

    var onPlayer1: (() -> Void)?
    var onPlayer2: (() -> Void)?
    var onUndo: (() -> Void)?
    
    init(onPlayer1:@escaping()->Void, onPlayer2:@escaping()->Void, onUndo:@escaping()->Void){
        self.onPlayer1 = onPlayer1
        self.onPlayer2 = onPlayer2
        self.onUndo = onUndo
    }

    /// Call this when a volume up press is detected
    func onButtonPressed() {
        pressCount += 1
        resetTimer?.invalidate()

        // Give user a short window to chain presses
        resetTimer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [weak self] _ in
            self?.handlePresses()
        }
    }

    private func handlePresses() {
        switch pressCount {
        case 1: onPlayer1?()
        case 2: onPlayer2?()
        case 3: onUndo?()
        default: break
        }

        // Reset counter for next sequence
        pressCount = 0
    }

    deinit {
        resetTimer?.invalidate()
    }
    
}
