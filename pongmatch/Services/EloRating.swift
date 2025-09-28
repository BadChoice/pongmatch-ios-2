import Foundation

struct EloRating {
    
    public  let mean = 1500
    private let kFactor:Int
    
    init(kFactor:Int = 32) {
        self.kFactor = kFactor
    }

    public func calculateNewRatings(player1Rating: Int, player2Rating: Int, didWinPlayer1: Int) -> Score.Result {
        // Work in Double for correct Elo math
        let r1 = Double(player1Rating)
        let r2 = Double(player2Rating)
        let k  = Double(kFactor)
        
        // Clamp outcome to 0 or 1
        let s1 = Double(didWinPlayer1 > 0 ? 1 : 0)
        
        // Expected scores
        let expectedScorePlayer1 = 1.0 / (1.0 + pow(10.0, (r2 - r1) / 400.0))
        let expectedScorePlayer2 = 1.0 - expectedScorePlayer1
        
        // New ratings
        let newRatingPlayer1Double = r1 + k * (s1 - expectedScorePlayer1)
        let newRatingPlayer2Double = r2 + k * ((1.0 - s1) - expectedScorePlayer2)
        
        // Round to nearest Int
        let newRatingPlayer1 = Int(newRatingPlayer1Double.rounded())
        let newRatingPlayer2 = Int(newRatingPlayer2Double.rounded())

        return Score.Result(
            newRatingPlayer1,
            newRatingPlayer2
        )
    }

}
