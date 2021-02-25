import Foundation

struct LoginUserBody: Codable {
    let type: String
    let username: String
    let password: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case username = "user"
        case password
    }
}


struct LoginUserResponse: Codable {
    let userID: String
    let accessToken: String
    let homeServer: String
    let deviceID: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case accessToken = "access_token"
        case homeServer = "home_server"
        case deviceID = "device_id"
    }
}
