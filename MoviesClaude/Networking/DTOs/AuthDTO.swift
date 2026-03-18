import Foundation

struct AuthDTO: Decodable {
    let success: Bool
    var statusCode: Int?
    var statusMessage: String?
}
