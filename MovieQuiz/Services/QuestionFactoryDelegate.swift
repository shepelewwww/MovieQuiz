//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Артем Шепелев on 15.01.2026.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(_ question: QuizQuestion?)
}
