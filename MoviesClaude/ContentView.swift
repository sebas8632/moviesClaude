//
//  ContentView.swift
//  MoviesClaude
//
//  Created by Juan Flores S on 16/03/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var viewModel: MoviesViewModel

    init(modelContext: ModelContext) {
        let repository = SwiftDataMovieRepository(modelContext: modelContext)
        _viewModel = StateObject(wrappedValue: MoviesViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            MoviesView(viewModel: viewModel)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .movieDetail(let movie):
                        MovieDetailView(movie: movie)
                    case .addMovie:
                        AddMovieView(viewModel: viewModel)
                    }
                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Movie.self, configurations: config)
    ContentView(modelContext: container.mainContext)
        .modelContainer(container)
}
