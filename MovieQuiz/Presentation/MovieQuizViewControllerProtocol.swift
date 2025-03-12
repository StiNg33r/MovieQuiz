protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(result: QuizResultsViewModel)
    
    func onHighlightImageBorder(isCorrectAnswer: Bool)
    func offHighlightImageBorder()
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func setQuestionState(isShowed: Bool)
    
    func showNetworkError(message: String)
}
