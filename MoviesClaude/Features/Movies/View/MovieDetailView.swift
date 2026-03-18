import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Label(String(movie.releaseYear), systemImage: "calendar")
                    Spacer()
                    if movie.rating > 0 {
                        Label(String(format: "%.1f", movie.rating), systemImage: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                    if movie.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if !movie.overview.isEmpty {
                    Text(movie.overview)
                        .font(.body)
                }
            }
            .padding()
        }
        .navigationTitle(movie.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}
