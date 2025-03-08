import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterResult(than result: GameResult) -> Bool{
        return correct > result.correct
    }
}
