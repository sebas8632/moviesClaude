import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "URL inválida."
        case .invalidResponse:      return "Respuesta inválida del servidor."
        case .statusCode(let code): return "Error HTTP \(code)."
        case .decoding(let error):  return "Error al decodificar: \(error.localizedDescription)"
        case .underlying(let error): return error.localizedDescription
        }
    }
}
