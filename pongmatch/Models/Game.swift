import Foundation

class Game : Codable {
    let id:Int?
    
    //initial_score
    let ranking_type:RankingType
    let winning_condition:WinningCondition
    
    let information:String?
    let date:Date
    
    var status:GameStatus
    var results:[[Int]]?
    
    let player1:User
    let player2:User
    
    
    init(id: Int? = nil, ranking_type: RankingType, winning_condition: WinningCondition, information: String? = nil, date: Date = Date(), status: GameStatus, results: [[Int]]? = nil, player1: User, player2: User) {
        self.id = id
        self.ranking_type = ranking_type
        self.winning_condition = winning_condition
        self.information = information
        self.date = date
        self.status = status
        self.results = results
        self.player1 = player1
        self.player2 = player2
    }
    
    var finalResult:[Int]? {
        guard let results, results.count > 0 else { return nil }
        
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
        [GameStatus.planned].contains(status)
    }
    
    func winner() -> User? {
        guard let finalResult = finalResult else { return nil }
        return finalResult[0] > finalResult[1] ? player1 : player2
    }
    
    @discardableResult
    func finish(_ score:Score) -> Self {
        results = score.sets.map { [$0.player1, $0.player2] }
        status = .finished
        return self
    }
    
    
    static func anonimus() -> Game {
        Game(
            id: -1,
            ranking_type: .friendly,
            winning_condition: .bestof3,
            information: nil,
            date: Date(),
            status: .ongoing,
            results: nil,
            player1: User.unknown(),
            player2: User.unknown()
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
