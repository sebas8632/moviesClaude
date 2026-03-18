import Foundation

enum MovieEndpoint: Endpoint {
    case popular(page: Int = 1)
    case search(query: String, page: Int = 1)
    case detail(movieId: Int)

    // Replace with your TMDB API key
    private static let apiKey = "a04eba640d9c956c16947b2ef20dd782"
    private static let baseURLString = "https://api.themoviedb.org/3"

    var baseURL: URL {
        URL(string: Self.baseURLString)!
    }

    var path: String {
        switch self {
        case .popular:           return "/movie/popular"
        case .search:            return "/search/movie"
        case .detail(let id):   return "/movie/\(id)"
        }
    }

    var method: HTTPMethod { .get }

    var headers: [String: String] {
        ["Content-Type": "application/json"]
    }

    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem(name: "api_key", value: Self.apiKey)]
        switch self {
        case .popular(let page):
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        case .search(let query, let page):
            items.append(URLQueryItem(name: "query", value: query))
            items.append(URLQueryItem(name: "page", value: "\(page)"))
        case .detail:
            break
        }
        return items
    }
}
