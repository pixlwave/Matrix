import Foundation

public struct ErrorResponse: Error, Decodable {
    public let code: String
    public let message: String
    
    enum CodingKeys: String, CodingKey {
        case code = "errcode"
        case message = "error"
    }
}
