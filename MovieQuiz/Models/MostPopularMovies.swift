//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by Артем Шепелев on 28.01.2026.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}
