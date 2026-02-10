import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []

    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
          self.moviesLoader = moviesLoader
          self.delegate = delegate
      }
    
    /*
    weak var delegate: QuestionFactoryDelegate?
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6??",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
   
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(_ : nil)
            return
        }
        
        let question = questions[index]
        delegate?.didReceiveNextQuestion(_ : question)
    }
     */
    
    func requestNextQuestion() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.didStartLoadingQuestion()
        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            guard !self.movies.isEmpty else { return }

            let index = Int.random(in: 0..<self.movies.count)
            let movie = self.movies[index]
            let url = movie.resizedImageURL

            var imageData = Data()
            do {
                imageData = try Data(contentsOf: url)
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.didFailToLoadData(with: QuestionFactoryError.failedToLoadImage)
                }
                return
            }

            let rating = Float(movie.rating) ?? 0
            let threshold = Float.random(in: 6...9)

            let comparisonIsGreater = Bool.random()
            let text: String
            let correctAnswer: Bool

            if comparisonIsGreater {
                text = "Рейтинг этого фильма больше чем \(String(format: "%.1f", threshold))?"
                correctAnswer = rating > threshold
            } else {
                text = "Рейтинг этого фильма меньше чем \(String(format: "%.1f", threshold))?"
                correctAnswer = rating < threshold
            }

            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)

            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didReceiveNextQuestion(question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let mostPopularMovies):
                if !mostPopularMovies.errorMessage.isEmpty {
                    self.delegate?.didFailToLoadData(
                        with: NSError(
                            domain: "IMDB API",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: mostPopularMovies.errorMessage]
                        )
                    )
                    return
                }

                self.movies = mostPopularMovies.items
                self.delegate?.didLoadDataFromServer()
                
            case .failure(let error):
                self.delegate?.didFailToLoadData(with: error)
            }
        }
    }
}



