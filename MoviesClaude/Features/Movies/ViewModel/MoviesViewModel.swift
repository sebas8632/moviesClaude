import Combine
import Foundation

final class MoviesViewModel: ObservableObject {
    @Published private(set) var movies: [Movie] = []
    @Published var errorMessage: String?

    private let repository: MovieRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(repository: MovieRepositoryProtocol) {
        self.repository = repository
        bindRepository()
    }

    func add(title: String, overview: String, releaseYear: Int) {
        let movie = Movie(title: title, overview: overview, releaseYear: releaseYear)
        do {
            try repository.add(movie)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            do {
                try repository.delete(movies[index])
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    func toggleFavorite(_ movie: Movie) {
        do {
            try repository.toggleFavorite(movie)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func bindRepository() {
        repository.moviesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] movies in
                self?.movies = movies
            }
            .store(in: &cancellables)
    }
}
