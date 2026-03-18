import Foundation

final class AuthAPIRepository: AuthRepositoryProtocol {
    private let client: HTTPClient

    init(client: HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }

    func authenticate() async throws -> AuthDTO {
        try await client.request(AuthEndpoint.authenticate)
    }
}
