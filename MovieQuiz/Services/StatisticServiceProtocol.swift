//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Артем Шепелев on 16.01.2026.
//

import Foundation

protocol StatisticServiceProtocol {
    var gameCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
