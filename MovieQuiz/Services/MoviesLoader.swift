import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    private let networkClient: NetworkRouting
    private let decoder = JSONDecoder()
    
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    private var mostPopularMoviesUrl: URL? {
        URL(string: "https://tv-api.com/en/API/Top250Movies/k_zcuw1ytf")
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        guard let url = mostPopularMoviesUrl else {
            handler(.failure(NetworkError.invalidURL))
            return
        }
        
        networkClient.fetch(url: url) { result in
            switch result {
            case .success(let data):
                do {
                    let movies = try decoder.decode(MostPopularMovies.self, from: data)
                    handler(.success(movies))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

