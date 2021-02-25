import Foundation

struct ErrorResponse: Error, Codable {
    let code: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case code = "errcode"
        case message = "error"
    }
}
