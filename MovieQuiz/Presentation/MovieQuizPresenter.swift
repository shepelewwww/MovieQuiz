import Foundation

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Strings
    private enum Strings {
        static let roundResult = "Результат раунда:"
        static let quizzesCount = "Количество сыгранных квизов:"
        static let record = "Рекорд:"
        static let averageAccuracy = "Средняя точность:"
        static let roundFinishedTitle = "Этот раунд окончен!"
        static let playAgainButton = "Сыграть ещё раз"
    }
    
    // MARK: - Properties
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    private let statisticService: StatisticServiceProtocol
    
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private let questionsAmount = 10
    private var correctAnswers = 0
    
    // MARK: - Init
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        self.statisticService = StatisticService()
        
        questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - User actions
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        
        let isCorrect = isYes == currentQuestion.correctAnswer
        if isCorrect { correctAnswers += 1 }
        
        viewController?.showAnswerResult(isCorrect: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.showNextQuestionOrResults()
        }
    }
    
    // MARK: - Navigation
    
    private func showNextQuestionOrResults() {
        if isLastQuestion() {
            let message = makeResultsMessage()
            let viewModel = QuizResultsViewModel(
                title: Strings.roundFinishedTitle,
                text: message,
                buttonText: Strings.playAgainButton
            )
            viewController?.show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let bestGame = statisticService.bestGame
        
        return """
            \(Strings.roundResult) \(correctAnswers)/\(questionsAmount)
            \(Strings.quizzesCount) \(statisticService.gameCount)
            \(Strings.record) \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            \(Strings.averageAccuracy) \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            imageData: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        guard let question = question else { return }
        
        currentQuestion = question
        
        let viewModel = QuizStepViewModel(
            imageData: question.image, // передаём Data
            question: question.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        
        viewController?.show(quiz: viewModel)
    }
    
    func didStartLoadingQuestion() {
        viewController?.showLoadingIndicator()
    }
}
