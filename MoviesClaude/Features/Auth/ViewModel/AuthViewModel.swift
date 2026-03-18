import Foundation
import Combine
@MainActor
final class AuthViewModel: ObservableObject {
    @Published var authResult: AuthDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol = AuthAPIRepository()) {
        self.repository = repository
    }

    func authenticate() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            authResult = try await repository.authenticate()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
