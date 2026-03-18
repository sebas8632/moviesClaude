import Foundation

protocol AuthRepositoryProtocol {
    func authenticate() async throws -> AuthDTO
}
