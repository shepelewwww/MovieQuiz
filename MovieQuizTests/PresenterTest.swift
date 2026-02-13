import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func setButtonsEnabled(_ isEnabled: Bool) {
        // intentionally left empty for testing
    }
    
    func show(quiz step: QuizStepViewModel) {
        // intentionally left empty for testing
    }
    
    func show(quiz result: QuizResultsViewModel) {
        // intentionally left empty for testing
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        // intentionally left empty for testing
    }
    
    func showLoadingIndicator() {
        // intentionally left empty for testing
    }
    
    func hideLoadingIndicator() {
        // intentionally left empty for testing
    }
    
    func showNetworkError(message: String) {
        // intentionally left empty for testing
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        
        let viewModel = sut.convert(model: question)
        
        XCTAssertEqual(viewModel.imageData, emptyData)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
