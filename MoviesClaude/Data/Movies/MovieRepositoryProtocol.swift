import Combine
import Foundation

protocol MovieRepositoryProtocol {
    var moviesPublisher: AnyPublisher<[Movie], Never> { get }
    func add(_ movie: Movie) throws
    func delete(_ movie: Movie) throws
    func toggleFavorite(_ movie: Movie) throws
}
