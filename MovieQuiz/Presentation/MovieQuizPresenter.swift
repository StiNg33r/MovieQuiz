import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let questionsAmount: Int = 10
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    private var currentQuestionIndex: Int = 0
    private var statisticService: StatisticServiceProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticService = StatisticService()
        viewController.showLoadingIndicator()
        
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame(needToReloadData: Bool) {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        if needToReloadData {
            questionFactory?.loadData()
        }
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
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)

    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let question = currentQuestion else {return}
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: question.correctAnswer == givenAnswer)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        
        currentQuestion = question
        viewController?.setQuestionState(isShowed: true)
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()

    }
    
    func didFailToLoadData(with error: Error) {
        viewController?.showNetworkError(message: error.localizedDescription)
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: self.questionsAmount)
            let quizResult = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                  text: """
                                                  Ваш результат: \(correctAnswers)/\(self.questionsAmount)
                                                  Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                                                  Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(self.questionsAmount) (\(statisticService?.bestGame.date.dateTimeString ?? ""))
                                                  Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
                                                  """,
                                                  buttonText: "Сыграть еще раз")
            
            viewController?.show(result: quizResult)
        }
        else{
            
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            
        }
    }
    
    private func proceedWithAnswer (isCorrect: Bool) {

        guard let viewController else { return }
        didAnswer(isCorrectAnswer: isCorrect)
        viewController.onHighlightImageBorder(isCorrectAnswer: isCorrect)
        viewController.setQuestionState(isShowed: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self, weak viewController] in
            guard let self, let viewController else { return }
            self.proceedToNextQuestionOrResults()
            viewController.offHighlightImageBorder()
        }
    }
    
}
