import Foundation

struct LoginUserBody: Encodable {
    let type: String
    let username: String
    let password: String
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case username = "user"
        case password
        case displayName = "initial_device_display_name"
    }
}


public struct LoginUserResponse: Decodable {
    public let userID: String
    public let accessToken: String
    public let deviceID: String
    
    @available(*, deprecated, message: "Extract the server_name from userID by splitting at the first colon.")
    public let homeserver: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case accessToken = "access_token"
        case deviceID = "device_id"
        
        case homeserver = "home_server"
    }
}
