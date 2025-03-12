
import XCTest
@testable import MovieQuiz

class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testScreenCast() throws {
        
        let queue = DispatchQueue(label: "testQueue")

        
        func tapButton(button: XCUIElement) {

            queue.async {
                sleep(2)
                DispatchQueue.main.async() {
                    button.tap()
                }
            }
        }
        let expectation = expectation(description: "Addition function expectation")
        
        let button = app.buttons["Да"]

        
        let button2 = app.buttons["Нет"]

        
        tapButton(button: button)
        tapButton(button: button)
        tapButton(button: button)
        tapButton(button: button2)
        tapButton(button: button2)
        tapButton(button: button2)
        tapButton(button: button2)
        tapButton(button: button2)
        tapButton(button: button2)
        tapButton(button: button)
        
        queue.async {
            sleep(10)
            DispatchQueue.main.async{
                self.app.alerts["Этот раунд окончен!"].scrollViews.otherElements.buttons["Сыграть еще раз"].tap()
                expectation.fulfill()
            }
        }
        
        
        waitForExpectations(timeout: 50)
        
    }
    
    func testYesButton() {
        
        sleep(2)
        let indexLabel = app.staticTexts["Index"]
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        XCTAssertTrue(firstPoster.exists)
        
        app.buttons["No"].tap() // находим кнопку `Да` и нажимаем её
        
        sleep(2)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        

        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertTrue(secondPoster.exists)
        XCTAssertTrue(indexLabel.label == "2/10")
        sleep(2)
        XCTAssertFalse(firstPosterData == secondPosterData) // проверяем, что постеры разные
    }
    
    
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts["Этот раунд окончен!"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
    }
    
    
    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Этот раунд окончен!"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
    
    
    func test() throws {
        
        
        
    }
}
    

