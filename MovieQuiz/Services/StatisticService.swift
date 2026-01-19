//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Артем Шепелев on 16.01.2026.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage = UserDefaults.standard
    
    private enum Keys {
        static let gamesCount = "gamesCount"
        static let bestGameCorrect = "bestGameCorrect"
        static let bestGameTotal = "bestGameTotal"
        static let bestGameDate = "bestGameDate"
        static let totalCorrect = "totalCorrect"
        static let totalQuestions = "totalQuestions"
    }
    
    var gameCount: Int {
        storage.integer(forKey: Keys.gamesCount)
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect)
            let total = storage.integer(forKey: Keys.bestGameTotal)
            let date = storage.object(forKey: Keys.bestGameDate) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
                storage.set(newValue.correct, forKey: Keys.bestGameCorrect)
                storage.set(newValue.total, forKey: Keys.bestGameTotal)
                storage.set(newValue.date, forKey: Keys.bestGameDate)
            }
    }
    
    var totalAccuracy: Double {
        let correct = storage.integer(forKey: Keys.totalCorrect)
        let total = storage.integer(forKey: Keys.totalQuestions)
        
        guard total > 0 else { return 0 }
        return Double(correct) / Double(total) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        storage.set(gameCount + 1, forKey: Keys.gamesCount)
        
        storage.set(
            storage.integer(forKey: Keys.totalCorrect) + count,
            forKey: Keys.totalCorrect
        )
        
        storage.set(
            storage.integer(forKey: Keys.totalQuestions) + amount,
            forKey: Keys.totalQuestions
        )
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        
        if currentGame.isBetterThan(bestGame) {
            storage.set(count, forKey: Keys.bestGameCorrect)
            storage.set(amount, forKey: Keys.bestGameTotal)
            storage.set(currentGame.date, forKey: Keys.bestGameDate)
        }
    }
}
