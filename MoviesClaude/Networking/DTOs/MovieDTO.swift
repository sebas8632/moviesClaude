import Foundation

struct MoviePageDTO: Decodable {
    let page: Int
    let results: [MovieDTO]
    let totalPages: Int
    let totalResults: Int
}

struct MovieDTO: Decodable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String?
    let voteAverage: Double
    let posterPath: String?

    var releaseYear: Int {
        guard let date = releaseDate, date.count >= 4,
              let year = Int(date.prefix(4)) else { return 0 }
        return year
    }

    func toDomain() -> Movie {
        Movie(
            title: title,
            overview: overview,
            releaseYear: releaseYear,
            rating: voteAverage
        )
    }
}
