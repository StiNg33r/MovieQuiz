import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    let questionsAmount: Int = 10
    var currentQuestion: QuizQuestion?
    var correctAnswers: Int = 0
    var questionFactory: QuestionFactoryProtocol?
    var statisticService: StatisticServiceProtocol?
    weak var viewController: MovieQuizViewController?
    
    private var currentQuestionIndex: Int = 0
    
    
    init(viewController: MovieQuizViewController, alertPresenter: AlertPresenterProtocol?) {
        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(
            delegate: self,
            moviesLoader: MoviesLoader(networkClient: NetworkClient()),
            alertPresenter: alertPresenter ?? AlertPresenter(delegate: viewController)
        )
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
    
    func didAnswer(isCorrectAnswer: Bool){
        correctAnswers += 1
    }
    
    private func didAnswer(isYes: Bool) {
        guard let question = currentQuestion, let viewController else {return}
        let givenAnswer = isYes
        viewController.showAnswerResult(isCorrect: question.correctAnswer == givenAnswer)
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
    
    func showNextQuestionOrResults(){
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
    
}
