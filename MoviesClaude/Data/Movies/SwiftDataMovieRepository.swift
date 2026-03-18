import Combine
import Foundation
import SwiftData

final class SwiftDataMovieRepository: MovieRepositoryProtocol {
    private let modelContext: ModelContext
    private let moviesSubject: CurrentValueSubject<[Movie], Never>

    var moviesPublisher: AnyPublisher<[Movie], Never> {
        moviesSubject.eraseToAnyPublisher()
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.moviesSubject = CurrentValueSubject([])
        refresh()
    }

    func add(_ movie: Movie) throws {
        modelContext.insert(movie)
        try modelContext.save()
        refresh()
    }

    func delete(_ movie: Movie) throws {
        modelContext.delete(movie)
        try modelContext.save()
        refresh()
    }

    func toggleFavorite(_ movie: Movie) throws {
        movie.isFavorite.toggle()
        try modelContext.save()
        refresh()
    }

    private func refresh() {
        let descriptor = FetchDescriptor<Movie>(sortBy: [SortDescriptor(\.title)])
        let movies = (try? modelContext.fetch(descriptor)) ?? []
        moviesSubject.send(movies)
    }
}
