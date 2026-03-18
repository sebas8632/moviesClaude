import SwiftUI

struct MoviesView: View {
    @ObservedObject var viewModel: MoviesViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        List {
            ForEach(viewModel.movies) { movie in
                MovieRowView(movie: movie)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        coordinator.navigate(to: .movieDetail(movie))
                    }
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Movies")
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            #endif
            ToolbarItem {
                Button {
                    coordinator.navigate(to: .addMovie)
                } label: {
                    Label("Add Movie", systemImage: "plus")
                }
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
