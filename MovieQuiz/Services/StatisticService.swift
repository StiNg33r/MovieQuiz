import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private enum Keys: String {
        case gamesCount = "gamesCount"
        case correctAnswers = "correctAnswers"
        case bestGameCorrect = "gameResult.correct"
        case bestGameTotal = "gameResult.total"
        case bestGameDate = "gameResult.date"
    }
    
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get {
            return storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set{
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var correctAnswers: Int {
        get {
            return storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    var totalAccuracy: Double {
        get {
            guard gamesCount != 0 else { return 0 }
            return Double(correctAnswers) / Double(gamesCount*10) * 100
        }
    }
    
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correctAnswers += count
        let result = GameResult(correct: count, total: amount, date: Date())
        if result.isBetterResult(than: bestGame) {
            bestGame = result
        }
    }
    
}
