import SwiftUI

struct GamePadInputHandler {
    //https://www.amazon.es/dp/B0C7BC5QM4?ref=ppx_yo2ov_dt_b_fed_asin_title
    
    var syncedScore = SyncedScore.shared
        
    func onInput(_ key: UIKeyCommand) {
        withAnimation {
            switch key.input {
            case "h": syncedScore.score.addScore(player: .player1)
            case "i": syncedScore.score.addScore(player: .player2)
            case "y": syncedScore.score.undo()
            case "j": syncedScore.score.redo()
            default: break
            }
            syncedScore.sync()
        }
    }
}



class VolumeButtonsHandler {
    private var pressCount = 0
    private var resetTimer: Timer?

    var syncedScore = SyncedScore.shared
    

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
        case 1: syncedScore.score.addScore(player: .player1)
        case 2: syncedScore.score.addScore(player: .player2)
        case 3: syncedScore.score.undo()
        default: break
        }

        // Reset counter for next sequence
        pressCount = 0
    }
    
    

    deinit {
        resetTimer?.invalidate()
    }
}
