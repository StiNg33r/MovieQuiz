import Foundation

final class QuestionFactory: QuestionFactoryProtocol{
    
    private let moviesLoader: MoviesLoading
    private let alertPresenter: AlertPresenterProtocol
    weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true
//        ),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        ),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false
//        )
//            
//    ]
    
    
    init(delegate: QuestionFactoryDelegate, moviesLoader: MoviesLoading, alertPresenter: AlertPresenterProtocol){
        self.delegate = delegate
        self.moviesLoader = moviesLoader
        self.alertPresenter = alertPresenter
        loadData()
    }
    
    func loadData() {
        print("LoadData")
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    //print(self.movies)
                    self.delegate?.didLoadDataFromServer()
                    
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                    
                }
            }
        }
    }
   
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
           
           do {
               imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                let alertModel = AlertModel(
                    title: "Ошибка",
                    message: "не удалось загрузить изображение",
                    buttonText: "попробовать еще раз",
                    completion: { [weak self] in
                        self?.requestNextQuestion()
                    }
                )
                alertPresenter.showAlert(model: alertModel)
                return
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let randomRating = Int.random(in: 7...9)
            let text = "Рейтинг этого фильма больше чем \(randomRating)?"
            let correctAnswer = rating > Float(randomRating)
            
            let question = QuizQuestion(image: imageData,
                                         text: text,
                                         correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
//    func requestNextQuestion() {
//        guard let index = (0..<questions.count).randomElement() else {
//            delegate?.didReceiveNextQuestion(question: nil)
//            return
//        }
//
//        let question = questions[safe: index]
//        delegate?.didReceiveNextQuestion(question: question)
//    }
    
}
