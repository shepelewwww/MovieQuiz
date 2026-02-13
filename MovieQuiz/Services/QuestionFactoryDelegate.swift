import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(_ question: QuizQuestion?)
    func didStartLoadingQuestion()
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
