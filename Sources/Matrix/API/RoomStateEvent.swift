import Foundation

public struct StateEvent: Codable {
    public let content: StateEventContent
    public let type: String
    public let eventID: String
    public let sender: String
    public let date: Date
//    public let unsigned: UnsignedData
    public let stateKey: String
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case stateKey = "state_key"
    }
    
    public struct StateEventContent: Codable {
        public let avatarURL: String?
        public let displayName: String?
        public let membership: Membership?
        public let isDirect: Bool?
        
        enum CodingKeys: String, CodingKey {
            case avatarURL = "avatar_url"
            case displayName = "displayname"
            case membership
            case isDirect = "is_direct"
        }
        
        public enum Membership: String, Codable {
            case invite, join, knock, leave, ban
        }
    }
}
