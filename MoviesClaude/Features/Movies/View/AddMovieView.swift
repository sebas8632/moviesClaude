import SwiftUI

struct AddMovieView: View {
    @ObservedObject var viewModel: MoviesViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var title = ""
    @State private var overview = ""
    @State private var releaseYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        Form {
            Section("Movie Info") {
                TextField("Title", text: $title)
                TextField("Overview", text: $overview, axis: .vertical)
                    .lineLimit(3...6)
                Stepper("Year: \(releaseYear)", value: $releaseYear, in: 1888...2100)
            }
        }
        .navigationTitle("Add Movie")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.add(title: title, overview: overview, releaseYear: releaseYear)
                    coordinator.pop()
                }
                .disabled(title.isEmpty)
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    coordinator.pop()
                }
            }
        }
    }
}
