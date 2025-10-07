import Foundation
import Combine

class Game : Codable {
    let id:Int
    
    let initial_score:InitialScore
    let ranking_type:RankingType
    let winning_condition:WinningCondition
    
    let information:String?
    let date:Date
    let round:Int?
    
    var status:GameStatus
    var results:[[Int]]?
    
    let player1:User?
    let player2:User?
    
    var safePlayer1:User {
        player1 ?? User.unknown()
    }
    
    var safePlayer2: User{
        player2 ?? User.unknown()
    }
    
    let dispute:Dispute?
    
    
    init(id: Int? = nil, initial_score:InitialScore, ranking_type: RankingType, winning_condition: WinningCondition, information: String? = nil, date: Date = Date(), status: GameStatus, results: [[Int]]? = nil, player1: User, player2: User, round:Int? = nil, dispute:Dispute? = nil, disputed_reason:String? = nil) {
        self.id = id ?? Int.random(in: 1...9999) * -1
        self.initial_score = initial_score
        self.ranking_type = ranking_type
        self.winning_condition = winning_condition
        self.information = information
        self.date = date
        self.status = status
        self.results = results
        self.player1 = player1
        self.player2 = player2
        self.dispute = dispute
        self.round = round
    }
    
    var needsId: Bool {
        id < 1
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
    
    func hasAnUnknownPlayer() -> Bool {
        [safePlayer1, safePlayer2].contains { $0.isUnknown }
    }
    
    func isFinished() -> Bool {
        status == .finished
    }
    
    func isUpcoming() -> Bool {
        [GameStatus.planned].contains(status)
    }
    
    func hasPlayer(_ player:User) -> Bool {
        [safePlayer1.id, safePlayer2.id].contains(player.id)
    }
    
    func winner() -> User? {
        guard let finalResult = finalResult else { return nil }
        return finalResult[0] > finalResult[1] ? player1 : player2
    }
    
    func isTheWinner(_ player:User?) -> Bool {
        guard let winner = winner() else { return false }
        return winner.id == player?.id
    }
    
    @discardableResult
    func finish(_ score:Score) -> Self {
        results = score.sets.map { [$0.player1, $0.player2] }
        status = .finished
        return self
    }
    
    
    func canBeDisputed() -> Bool {
        status == .finished
        && dispute == nil
        //&& ranking_type == .competitive
        //&& date.addingTimeInterval(7*24*60*60) > Date() // 7 Days margin
    }
    
    static func anonimus() -> Game {
        Game(
            id: Int.random(in: 1...9999) * -1,
            initial_score: .standard,
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
    
    static func fake(id:Int? = nil, status:GameStatus = .planned, player1:User = User.me(), player2:User = User.unknown(), round:Int? = nil) -> Game {
        Game(
            id: id ?? Int.random(in: 1...9999) * -1,
            initial_score: .standard,
            ranking_type: .competitive,
            winning_condition: .bestof3,
            information: "A fake game",
            date: Date(),
            status: status,
            results: [[11, 7], [5, 11], [11, 9]],
            player1: player1,
            player2: player2,
            round:round
        )
    }
    
    static func fakeDisputed() -> Game {
        Game(
            id: Int.random(in: 1...9999) * -1,
            initial_score: .standard,
            ranking_type: .competitive,
            winning_condition: .bestof3,
            information: "A fake game",
            date: Date(),
            status: .finished,
            results: [[11, 7], [5, 11], [11, 9]],
            player1: User.me(),
            player2: User.opponent(),
            //dispute:Dispute(id: 1, reason: "A Fake dispute", game_id: 1, user_id: 1, status: .open, created_at: Date())
            //
            dispute:Dispute(id: 1, reason: "A Fake dispute", game_id: 1, user_id: 1, created_at: Date())
        )
    }
}
