import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - IBActions
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(
            isCorrect: givenAnswer == currentQuestion.correctAnswer
        )
    }
    
    // MARK: - Private Properties
    private var correctAnswers = 0
    private var questionFactory: QuestionFactoryProtocol!
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenter!
    private var statisticService: StatisticServiceProtocol!
    
    private let presenter = MovieQuizPresenter()
    
    enum Strings {
        static let roundResult = "Результат раунда:"
        static let quizzesCount = "Количество сыгранных квизов:"
        static let record = "Рекорд:"
        static let averageAccuracy = "Средняя точность:"
        static let roundFinishedTitle = "Этот раунд окончен!"
        static let playAgainButton = "Сыграть ещё раз"
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    private func setupAlertPresenter() {
        alertPresenter = AlertPresenter(viewController: self)
    }
    
    private func requestFirstQuestion() {
        questionFactory.requestNextQuestion()
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще") { [weak self] in
                guard let self else { return }
                self.correctAnswers = 0
                self.questionFactory.requestNextQuestion()
            }
        alertPresenter.showAlert(model: model)
    }
    
    // MARK: - UI
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = UIImage(data: step.image) ?? UIImage()
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        setButtonEnabled(true)
    }
    
    // MARK: - Quiz Logic
    private func showAnswerResult(isCorrect: Bool) {
        setButtonEnabled(false)
        
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor =
        isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        imageView.layer.cornerRadius = 20
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            showFinalResult()
            return
        }
        
        presenter.switchToNextQuestion()
        questionFactory.requestNextQuestion()
    }
    
    private func showFinalResult() {
        statisticService.store(
            correct: correctAnswers,
            total: presenter.totalQuestions
        )
        
        let bestGame = statisticService.bestGame
        
        let resultText = """
            \(Strings.roundResult) \(correctAnswers)/\(presenter.questionsAmount)
            \(Strings.quizzesCount) \(statisticService.gameCount)
            \(Strings.record) \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            \(Strings.averageAccuracy) \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
        
        let alertModel = AlertModel(
            title: Strings.roundFinishedTitle,
            message: resultText,
            buttonText: Strings.playAgainButton
        ) { [weak self] in
            guard let self else { return }
            
            self.correctAnswers = 0
            self.presenter.resetQuestionIndex()
            self.questionFactory.requestNextQuestion()
        }
        alertPresenter.showAlert(model: alertModel)
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "-" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func showNetworkErrorAlert(retryHandler: @escaping () -> Void) {
        let alert = UIAlertController(
            title: AlertText.title,
            message: AlertText.message,
            preferredStyle: .alert
        )
        let retryAction = UIAlertAction(title: AlertText.retry, style: .default) { _ in
            retryHandler()
        }
        let cancelAction = UIAlertAction(title: AlertText.cancel, style: .cancel)
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func setButtonEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        DispatchQueue.main.async { [weak self] in
            guard let self, let question else { return }

            self.hideLoadingIndicator()
            self.currentQuestion = question

            let viewModel = presenter.convert(model: question)
            self.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        DispatchQueue.main.async {
            self.hideLoadingIndicator()
            self.questionFactory.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didStartLoadingQuestion() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
}
