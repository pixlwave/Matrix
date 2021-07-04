import Foundation

public struct RoomEvent: Codable {
    public let content: RoomEventContent
    public let type: String
    public let eventID: String
    public let sender: String
    public let date: Date
    public let unsigned: UnsignedData?
    
    // state events (required)
    public let stateKey: String?
    
    // m.room.redaction
    public let redacts: String?
    
    enum CodingKeys: String, CodingKey {
        case content
        case type
        case eventID = "event_id"
        case sender
        case date = "origin_server_ts"
        case unsigned
        case stateKey = "state_key"
        case redacts
    }
    
    public struct RoomEventContent: Codable {
        // m.room.message (required)
        public let body: String?
        public let type: MessageType?
        // (optional)
        public let relationship: Relationship?
        public let url: URL?
        
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
            case type = "msgtype"
            case relationship = "m.relates_to"
            case url
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
        
        public enum MessageType: String, Codable {
            case text = "m.text"
            case emote = "m.emote"
            case notice = "m.notice"
            case image = "m.image"
            case file = "m.file"
            case audio = "m.audio"
            case location = "m.location"
            case video = "m.video"
            case unknown
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self = MessageType(rawValue: (try? container.decode(String.self)) ?? "") ?? .unknown
            }
        }
        
        public enum Membership: String, Codable {
            case invite, join, knock, leave, ban, unknown
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self = Membership(rawValue: (try? container.decode(String.self)) ?? "") ?? .unknown
            }
        }
    }
    
    public struct UnsignedData: Codable {
        public let transactionID: String?
        
        enum CodingKeys: String, CodingKey {
            case transactionID = "transaction_id"
        }
    }
}
