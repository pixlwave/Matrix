import Foundation

public struct RoomEvent: Codable {
    public let content: RoomEventContent
    public let type: String
    public let eventID: String
    public let sender: String
    public let date: Date
//    public let unsigned: UnsignedData
    
    // state events
    public let stateKey: String?
    
    // m.room.redaction
    public let redacts: String?
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case stateKey = "state_key"
        case redacts
    }
    
    public struct RoomEventContent: Codable {
        // m.room.message
        public let body: String?
        public let relationship: Relationship?
        
        // edit event
        public let newContent: NewContent?
        
        // m.room.redaction
        public let reason: String?
        
        // MARK: State Event Content
        // m.room.name
        public let name: String?
        
        // m.room.membership
        public let avatarURL: String?
        public let displayName: String?
        public let membership: Membership?
        public let isDirect: Bool?
        
        enum CodingKeys: String, CodingKey {
            case body
            case relationship = "m.relates_to"
            case newContent = "m.new_content"
            case reason
            
            // state
            case name
            case avatarURL = "avatar_url"
            case displayName = "displayname"
            case membership
            case isDirect = "is_direct"
        }
        
        public struct NewContent: Codable {
            public let body: String?
        }
        
        public enum Membership: String, Codable {
            case invite, join, knock, leave, ban
        }
    }
}
