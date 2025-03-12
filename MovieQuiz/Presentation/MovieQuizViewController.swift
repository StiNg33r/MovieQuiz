import UIKit

final class MovieQuizViewController: UIViewController,
                                     AlertPresenterDelegate {
    
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    private var questionIsShowed = true
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertPresenter = AlertPresenter(delegate: self)
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self, alertPresenter: alertPresenter)

        
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - AlertPresenterDelegate
    
    func showAlert(alert: UIAlertController) {
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    func setQuestionState(isShowed: Bool) {
        questionIsShowed = isShowed
    }
    
     func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.isHidden = false
            self?.activityIndicator.startAnimating()
        }
    }
    
     func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
        }
    }
    
     func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let completion = { [weak self] in
            guard let self = self else { return }
            
            self.presenter?.restartGame(needToReloadData: true)
        }
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз",
            completion: completion
        )
        alertPresenter?.showAlert(model: alertModel)
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    func showAnswerResult (isCorrect: Bool){
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrect{
            presenter?.didAnswer(isCorrectAnswer: true)
            imageView.layer.borderColor = UIColor.YpGreen.cgColor
        }
        else{
            imageView.layer.borderColor = UIColor.YpRed.cgColor
        }
        
        questionIsShowed = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.imageView.layer.borderWidth = 0
            self.presenter?.showNextQuestionOrResults()
        }
    }
    
    func show(result: QuizResultsViewModel){
        
        let completion: () -> Void = { [weak self]  in
            guard let self else { return }
            self.presenter?.restartGame(needToReloadData: false)
        }
        
        let alertModel = AlertModel(title: result.title,
                                    message: result.text,
                                    buttonText: result.buttonText,
                                    completion: completion)
        
        
        alertPresenter?.showAlert(model: alertModel)

    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        if questionIsShowed {
            presenter?.yesButtonClicked()
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        if questionIsShowed {
            presenter?.noButtonClicked()
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
