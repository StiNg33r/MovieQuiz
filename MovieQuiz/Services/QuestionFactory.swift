import Foundation

final class QuestionFactory: QuestionFactoryProtocol{
    
    private let moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    var alertPresenter: AlertPresenterProtocol?
    weak var delegate: QuestionFactoryDelegate?
    
    
    init(delegate: QuestionFactoryDelegate, moviesLoader: MoviesLoading){
        self.delegate = delegate
        self.moviesLoader = moviesLoader
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
                alertPresenter?.showAlert(model: alertModel)
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
    
    
}
