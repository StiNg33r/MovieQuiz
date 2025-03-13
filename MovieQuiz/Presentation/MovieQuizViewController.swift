import UIKit

final class MovieQuizViewController: UIViewController,
                                     AlertPresenterDelegate,
                                     MovieQuizViewControllerProtocol {
    
    
    
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
        presenter = MovieQuizPresenter(viewController: self)
        let questionFactory = QuestionFactory(
            delegate: presenter ?? MovieQuizPresenter(viewController: self),
            moviesLoader: MoviesLoader(networkClient: NetworkClient())
        )
        questionFactory.alertPresenter = alertPresenter
        presenter?.questionFactory = questionFactory

        
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
    
    
    
    func onHighlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        if isCorrectAnswer {
            imageView.layer.borderColor = UIColor.YpGreen.cgColor
        }
        else {
            imageView.layer.borderColor = UIColor.YpRed.cgColor
        }
    }
    
    func offHighlightImageBorder() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.imageView.layer.borderWidth = 0
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
