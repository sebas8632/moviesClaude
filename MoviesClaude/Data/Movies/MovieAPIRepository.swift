import Foundation

protocol MovieAPIRepositoryProtocol {
    func fetchPopular(page: Int) async throws -> [Movie]
    func search(query: String, page: Int) async throws -> [Movie]
}

final class MovieAPIRepository: MovieAPIRepositoryProtocol {
    private let client: HTTPClient

    init(client: HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }

    func fetchPopular(page: Int = 1) async throws -> [Movie] {
        let response: MoviePageDTO = try await client.request(MovieEndpoint.popular(page: page))
        return response.results.map { $0.toDomain() }
    }

    func search(query: String, page: Int = 1) async throws -> [Movie] {
        let response: MoviePageDTO = try await client.request(MovieEndpoint.search(query: query, page: page))
        return response.results.map { $0.toDomain() }
    }
}
