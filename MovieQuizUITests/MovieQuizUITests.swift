import XCTest

class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }

    func testYesButtonChangesPoster() {
        // находим первый постер
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        // нажимаем "Yes"
        app.buttons["Yes"].tap()
        sleep(2) // подождать пока картинка обновится

        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }

    func testNoButtonUpdatesIndex() {
        let firstPoster = app.images["Poster"]
        _ = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap()
        sleep(2)

        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }

    func testGameFinishAlertAppears() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1)
        }

        let alert = app.alerts["GameResultsAlert"] // ищем по идентификатору
        XCTAssertTrue(alert.waitForExistence(timeout: 5))

        let playAgainButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(playAgainButton.exists)
    }

    func testAlertDismissResetsGame() {
        // Проходим все 10 вопросов
        for _ in 1...10 {
            let noButton = app.buttons["No"]
            XCTAssertTrue(noButton.waitForExistence(timeout: 2))
            noButton.tap()
        }

        // Находим alert
        let alert = app.alerts["GameResultsAlert"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))

        // Нажимаем кнопку "Сыграть ещё раз"
        let playAgainButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(playAgainButton.exists)
        playAgainButton.tap()

        // Ждём, пока alert исчезнет
        XCTAssertFalse(alert.waitForExistence(timeout: 5), "Alert должен исчезнуть после нажатия на кнопку")

        // Проверяем, что индекс вопросов сбросился
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 2))
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
