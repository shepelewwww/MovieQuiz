import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {

    // MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!

    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!

    // MARK: - IBActions
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
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
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?

    private var alertPresenter: AlertPresenter!
    private var statisticService: StatisticServiceProtocol!

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

        statisticService = StatisticService()

        let factory = QuestionFactory()
        factory.setup(delegate: self)
        questionFactory = factory

        alertPresenter = AlertPresenter(viewController: self)

        questionFactory.requestNextQuestion()
    }

    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(_ question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    // MARK: - UI
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber

        setButtonEnabled(true)
    }

    /* private func show(quiz result: QuizResultsViewModel) {
     let alert = UIAlertController(
     title: result.title,
     message: result.text,
     preferredStyle: .alert
     )
    
     let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
     guard let self = self else { return }
    
     self.currentQuestionIndex = 0
     self.correctAnswers = 0
     self.questionFactory.requestNextQuestion()
     }
    
     alert.addAction(action)
     present(alert, animated: true)
     }*/

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
        if currentQuestionIndex >= questionsAmount - 1 {
            showFinalResult()
            return
        }

        currentQuestionIndex += 1
        questionFactory.requestNextQuestion()
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }

    private func showFinalResult() {
        statisticService.store(
            correct: correctAnswers,
            total: questionsAmount
        )

        let bestGame = statisticService.bestGame

        let resultText = """
            \(Strings.roundResult) \(correctAnswers)/\(questionsAmount)
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

            self.currentQuestionIndex = 0
            self.correctAnswers = 0
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
            title: "Ошибка",
            message: "Что-то пошло не так. Попробовать снова?",
            preferredStyle: .alert
        )
        let retryAction = UIAlertAction(title: "Повторить", style: .default) {
            _ in
            retryHandler()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func setButtonEnabled(_ isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
}
