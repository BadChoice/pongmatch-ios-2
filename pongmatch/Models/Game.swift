import Foundation

struct Game : Codable {
    let id:Int?
    
    //initial_score
    let ranking_type:RankingType
    let winning_condition:WinningCondition
    
    let information:String?
    let date:Date
    let status:GameStatus
    let results:[[Int]]?
    let finalResult:[Int]?
    //let created_at:Date
    //let updated_at:Date?
    
    let player1:User
    let player2:User
    
    func isFinished() -> Bool {
        status == .finished
    }
    
    func isUpcoming() -> Bool {
        [GameStatus.planned, GameStatus.waitingOpponent].contains(status)
    }
    
    func winner() -> User? {
        guard let finalResult = finalResult else { return nil }
        return finalResult[0] > finalResult[1] ? player1 : player2
    }
    
    
    static func fromScore(_ score:Score) -> Game {
        Game(
            id: nil,
            ranking_type: score.rankingType,
            winning_condition: score.winningCondition,
            information: nil,
            date: score.started_at,
            status: .finished,
            results: score.sets.map { [$0.player1, $0.player2] },
            finalResult: [score.setsResult.player1, score.setsResult.player2],
            player1: score.player1,
            player2: score.player2
        )
    }
    
    static func fake() -> Game {
        Game(
            id: -1,
            ranking_type: .competitive,
            winning_condition: .bestof3,
            information: "A fake game",
            date: Date(),
            status: .planned,
            results: nil,
            finalResult: [2, 1],
            player1: User.me(),
            player2: User.unknown()
        )
    }
}
