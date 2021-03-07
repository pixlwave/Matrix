import Foundation

struct RegisterUserBody: Codable {
    let username: String
    let password: String
    let auth: [String: String]
}


public struct RegisterUserResponse: Codable {
    public let accessToken: String
    public let homeServer: String
    public let userID: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case homeServer = "home_server"
        case userID = "user_id"
    }
}
