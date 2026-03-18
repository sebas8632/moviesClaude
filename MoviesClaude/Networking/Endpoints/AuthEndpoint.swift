import Foundation

enum AuthEndpoint: Endpoint {
    case authenticate

    private static let bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhMDRlYmE2NDBkOWM5NTZjMTY5NDdiMmVmMjBkZDc4MiIsIm5iZiI6MTc3Mzg2MzkxNC4xNTEsInN1YiI6IjY5YmIwM2VhYTAzYmJiZjA4NDliMzYzYyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.sr_lHw8ODkNeZSfWFfkTiPbrIkLVxMKpLs0G7hGmeTU"
    private static let baseURLString = "https://api.themoviedb.org/3"

    var baseURL: URL {
        URL(string: Self.baseURLString)!
    }

    var path: String { "/authentication" }

    var method: HTTPMethod { .get }

    var headers: [String: String] {
        [
            "accept": "application/json",
            "Authorization": "Bearer \(Self.bearerToken)"
        ]
    }

    var queryItems: [URLQueryItem] { [] }
}
