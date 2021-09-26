import Foundation

public struct WellKnownResponse: Decodable {
    public let homeserver: HomeserverInformation
    public let identityServer: IdentityServerInformation?
    
    enum CodingKeys: String, CodingKey {
        case homeserver = "m.homeserver"
        case identityServer = "m.identity_server"
    }
    
    public struct HomeserverInformation: Decodable {
        public let baseURL: URL
        
        enum CodingKeys: String, CodingKey {
            case baseURL = "base_url"
        }
    }
    
    public struct IdentityServerInformation: Decodable {
        public let baseURL: URL
        
        enum CodingKeys: String, CodingKey {
            case baseURL = "base_url"
        }
    }
}
