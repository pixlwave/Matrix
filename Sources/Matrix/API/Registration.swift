import Foundation

struct RegisterUserBody: Codable {
    let username: String
    let password: String
    let auth: [String: String]
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case password
        case auth
        case displayName = "initial_device_display_name"
    }
}


public struct RegisterUserResponse: Codable {
    public let userID: String
    public let accessToken: String
    public let homeserver: String
    public let deviceID: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case accessToken = "access_token"
        case homeserver = "home_server"
        case deviceID = "device_id"
    }
}
