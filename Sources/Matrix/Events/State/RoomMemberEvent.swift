import Foundation

public struct RoomMemberEvent: RoomEvent {
    public static var type = "m.room.member"
    
    public let content: Content
    public let type: String
    public let eventID: String
    public let sender: String
    public let date: Date
    public let unsigned: UnsignedData?
    
    public let stateKey: String?
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
        case stateKey = "state_key"
    }
    
    public struct Content: Decodable {
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
    }
}
