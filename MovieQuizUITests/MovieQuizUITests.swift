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
        // Идем по всем 10 вопросам, отвечая "No"
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(1) // даем время UI обновиться
        }

        // Находим alert по заголовку
        let alert = app.alerts["Этот раунд окончен!"]
        
        // Проверяем, что alert появился
        XCTAssertTrue(alert.exists, "Alert с заголовком 'Этот раунд окончен!' должен появиться")
        
        // Проверяем, что кнопка "Сыграть ещё раз" существует
        let playAgainButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(playAgainButton.exists, "Кнопка 'Сыграть ещё раз' должна быть доступна в alert")
    }

    func testAlertDismissResetsGame() {
        for _ in 1...10 {
            app.buttons["No"].tap()
        }

        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 5))

        let playAgainButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(playAgainButton.exists)
        playAgainButton.tap()

        XCTAssertFalse(alert.waitForExistence(timeout: 2))

        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
