//
//  Item.swift
//  MoviesClaude
//
//  Created by Juan Flores S on 16/03/26.
//

import Foundation
import SwiftData

@Model
final class Movie {
    var id: UUID
    var title: String
    var overview: String
    var releaseYear: Int
    var rating: Double
    var isFavorite: Bool

    init(title: String, overview: String = "", releaseYear: Int, rating: Double = 0.0) {
        self.id = UUID()
        self.title = title
        self.overview = overview
        self.releaseYear = releaseYear
        self.rating = rating
        self.isFavorite = false
    }
}
