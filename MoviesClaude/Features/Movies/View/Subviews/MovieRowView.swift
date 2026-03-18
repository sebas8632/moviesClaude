import SwiftUI

struct MovieRowView: View {
    let movie: Movie

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                Text(String(movie.releaseYear))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if movie.rating > 0 {
                Label(String(format: "%.1f", movie.rating), systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            }
            if movie.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }
}
