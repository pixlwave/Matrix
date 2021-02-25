import Foundation

struct RegisterUserBody: Codable {
    let username: String
    let password: String
    let auth: [String: String]
}


struct RegisterUserResponse: Codable {
    let accessToken: String
    let homeServer: String
    let userID: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case homeServer = "home_server"
        case userID = "user_id"
    }
}
