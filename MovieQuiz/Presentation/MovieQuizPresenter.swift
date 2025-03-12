import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        guard let question = currentQuestion, let viewController else {return}
        let givenAnswer = true
        viewController.showAnswerResult(isCorrect: question.correctAnswer == givenAnswer)
        

    }
    func noButtonClicked() {
        guard let question = currentQuestion, let viewController else {return}
        let givenAnswer = false
        viewController.showAnswerResult(isCorrect: question.correctAnswer == givenAnswer)
        

    }
    
}
