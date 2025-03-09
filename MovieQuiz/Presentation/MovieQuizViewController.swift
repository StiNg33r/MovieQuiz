import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    
    private let questionsAmount: Int = 10

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var questionIsShowed = true
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var currentQuestion: QuizQuestion?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticService()
        questionFactory?.requestNextQuestion()
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {return}
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - AlertPresenterDelegate
    func showAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
      let questionStep = QuizStepViewModel(
        image: UIImage(named: model.image) ?? UIImage(),
        question: model.text,
        questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)"
      )
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    private func showAnswerResult (isCorrect: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect{
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.YpGreen.cgColor
        }
        else{
            imageView.layer.borderColor = UIColor.YpRed.cgColor
        }
        
        questionIsShowed = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
           self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults(){
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let quizResult = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                  text: """
                                                  Ваш результат: \(correctAnswers)/\(questionsAmount)
                                                  Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
                                                  Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(questionsAmount) (\(statisticService?.bestGame.date.dateTimeString ?? ""))
                                                  Средняя точность: \(String(format: "%.2f", statisticService?.totalAccuracy ?? 0))%
                                                  """,
                                                  buttonText: "Сыграть еще раз")
            show(result: quizResult)
        }
        else{
            currentQuestionIndex += 1
            
            questionFactory?.requestNextQuestion()
            
        }
        questionIsShowed = true
        imageView.layer.borderWidth = 0
    }

    private func show(result: QuizResultsViewModel){
        
        let completion: () -> Void = { [weak self]  in
            guard let self else { return }
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        let alertModel = AlertModel(title: result.title,
                                    message: result.text,
                                    buttonText: result.buttonText,
                                    completion: completion)
        
        
        alertPresenter?.showAlert(model: alertModel)

    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let question = currentQuestion else {return}
        if questionIsShowed{
            showAnswerResult(isCorrect: question.correctAnswer == true)
        }

    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let question = currentQuestion else {return}
        if questionIsShowed{
            showAnswerResult(isCorrect: question.correctAnswer == false)
        }
    }
}




/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
