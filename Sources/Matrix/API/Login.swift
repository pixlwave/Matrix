import Foundation

struct LoginUserBody: Encodable {
    let type: String
    let identifier: UserIdentifier
    let password: String
    let displayName: String?
    
    enum CodingKeys: String, CodingKey {
        case type
        case identifier
        case password
        case displayName = "initial_device_display_name"
    }
    
    public enum UserIdentifier: Encodable {
        case user(String)
        
        enum CodingKeys: String, CodingKey {
            case user
            case type
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .user(let id):
                try container.encode("m.id.user", forKey: .type)
                try container.encode(id, forKey: .user)
            }
        }
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
