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
    
    let player1:User
    let player2:User
    
    var finalResult:[Int]? {
        guard let results else { return nil }
        
        let player1 = results.reduce(0) { partialResult, set in
            partialResult + (set[0] > set[1] ? 1 : 0)
        }
        let player2 = results.reduce(0) { partialResult, set in
            partialResult + (set[1] > set[0] ? 1 : 0)
        }
        return [player1, player2]
    }
    
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
            results: [[11, 7], [5, 11], [11, 9]],
            player1: User.me(),
            player2: User.unknown()
        )
    }
}
